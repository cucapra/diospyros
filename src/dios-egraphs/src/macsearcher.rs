use egg::{*};

use std::str::FromStr;

use crate::{
    veclang::{VecLang},
    searchutils::*
};

#[derive(Debug, PartialEq, Clone)]
pub struct MacSearcher {
    pub full_mac_pattern: Pattern<VecLang>,
    pub vec4_pattern: Pattern<VecLang>,
    pub add_mul_pattern: Pattern<VecLang>,
    pub mul_pattern: Pattern<VecLang>,
    pub zero_pattern: Pattern<VecLang>,
}

pub fn build_mac_searcher() -> MacSearcher {
    let full_mac_pattern = "(Vec4 (+ ?a0 (* ?b0 ?c0))
                                  (+ ?a1 (* ?b1 ?c1))
                                  (+ ?a2 (* ?b2 ?c2))
                                  (+ ?a3 (* ?b3 ?c3)))"
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let vec4_pattern = "(Vec4 ?w ?x ?y ?z)"
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let add_mul_pattern = "(+ ?a (* ?b ?c))"
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let mul_pattern = "(* ?b ?c)"
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let zero_pattern = "0"
        .parse::<Pattern<VecLang>>()
        .unwrap();

    MacSearcher {
        full_mac_pattern,
        vec4_pattern,
        add_mul_pattern,
        mul_pattern,
        zero_pattern,
    }
}

impl MacSearcher {
}

// We want each lane (?w, ?x, ?y, ?z) in (Vec4 ?w ?x ?y ?z) to match either:
//     (+ ?a (* ?b ?c))
//     (* ?b ?c)           here, map ?a -> 0
//     0                   here, map ?a -> 0, ?b -> 0, ?c -> 0
impl<A: Analysis<VecLang>> Searcher<VecLang, A> for MacSearcher {
    fn search_eclass(&self, egraph: &EGraph<VecLang, A>, eclass: Id) -> Option<SearchMatches> {
        let vec4_matches = self.vec4_pattern.search_eclass(egraph, eclass);
        let vec4_mac_compatible = match vec4_matches {
            None => None,
            Some(matches) => {
                // Now we know the eclass is a Vec4. The question is: does it
                // match a pattern compatible with a MAC?
                let mut new_substs : Vec<Subst> = Vec::new();
                let zero_id = egraph.lookup(VecLang::Num(0)).unwrap();

                // For each set of substitutions
                for substs in matches.substs.iter() {
                    let mut all_matches_found = true;
                    let mut new_substs_options : Vec<Vec<Vec<(Var, Id)>>> = Vec::new();

                    // For each variable w, x, y, z in (Vec4 ?w ?x ?y ?z).
                    // We use the index i to disambiguate lanes, so we can have,
                    // for example, ?a0 through ?a3
                    for (i, vec4_var) in self.vec4_pattern.vars().iter().enumerate() {

                        // TODO: abstract this out to be prettier
                        let mut new_var_substs : Vec<Vec<(Var, Id)>> = Vec::new();

                        // Check if that variable matches add/mul
                        let child_eclass = substs.get(*vec4_var).unwrap();
                        if let Some(add_mul_match) = self.add_mul_pattern.search_eclass(egraph, *child_eclass) {
                            for s in add_mul_match.substs.iter() {
                                let mut subs : Vec<(Var, Id)> = Vec::new();
                                for add_mul_var in self.add_mul_pattern.vars().iter() {
                                    let new_v = Var::from_str(&format!("{}{}", *add_mul_var, i)).unwrap();
                                    subs.push((new_v, *s.get(*add_mul_var).unwrap()));
                                }
                                new_var_substs.push(subs);
                            }
                        // Check if that variable matches just a mul
                        } else if let Some(mul_match) = self.mul_pattern.search_eclass(egraph, *child_eclass) {
                            for s in mul_match.substs.iter() {
                                let mut subs : Vec<(Var, Id)> = Vec::new();
                                // for ?b and ?c
                                for mul_var in self.mul_pattern.vars().iter() {
                                    let new_v = Var::from_str(&format!("{}{}", *mul_var, i)).unwrap();
                                    subs.push((new_v, *s.get(*mul_var).unwrap()));
                                }
                                // ?a needs to map to a zero!
                                let var_a = Var::from_str(&format!("?a{}", i)).unwrap();
                                subs.push((var_a, zero_id));
                                new_var_substs.push(subs);
                            }
                        // This lane is just 0
                        } else if let Some(_) = self.zero_pattern.search_eclass(egraph, *child_eclass) {
                            // ?a, ?b, and ?c all map to zero
                            let subs : Vec<(Var, Id)> = vec![
                                (Var::from_str(&format!("?a{}", i)).unwrap(), zero_id),
                                (Var::from_str(&format!("?b{}", i)).unwrap(), zero_id),
                                (Var::from_str(&format!("?c{}", i)).unwrap(), zero_id),
                            ];
                            new_var_substs.push(subs);

                        // This lane isn't compatible, so the whole Vec4 can't
                        // be a MAC
                        } else {
                            all_matches_found = false;
                            break;
                        }
                        new_substs_options.push(new_var_substs);
                    }
                    if all_matches_found {
                        // Now there is at least one match, but we need to make
                        // potentially > 1 subst as children are combinatorial
                        let mut all_substs = all_matches_to_substs(&new_substs_options);
                        new_substs.append(&mut all_substs);
                    }
                };
                if new_substs.is_empty() {
                    None
                } else {
                    Some(SearchMatches {
                        eclass : matches.eclass,
                        substs : new_substs,
                    })
                }
            }
        };
        vec4_mac_compatible
    }

    fn vars(&self) -> Vec<Var> {
        self.full_mac_pattern.vars()
    }
}
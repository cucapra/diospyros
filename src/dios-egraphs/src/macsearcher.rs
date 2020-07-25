use egg::{*};

use std::str::FromStr;

#[derive(Debug, PartialEq, Clone)]
pub struct MacSearcher<L> {
    pub full_mac_pattern: Pattern<L>,
    pub vec4_pattern: Pattern<L>,
    pub add_mul_pattern: Pattern<L>,
    pub mul_pattern: Pattern<L>,
    pub zero_pattern: Pattern<L>,
}

impl<L: Language> MacSearcher<L> {
}

// Either want:
// (+ ?a (* ?b ?c))
// (* ?b ?c)
// 0


// (Vec4 (+ ?a (* ?b ?c))
//       (+ ?d (* ?e ?f))
//       (+ ?g (* ?h ?i))
//       (+ ?j (* ?k ?l)))
pub fn build_mac_searcher<L: Language>() -> MacSearcher<L> {
    let full_mac_pattern : Pattern<L> = "(Vec4 (+ ?a0 (* ?b0 ?c0))
                                               (+ ?a1 (* ?b1 ?c1))
                                               (+ ?a2 (* ?b2 ?c2))
                                               (+ ?a3 (* ?b3 ?c3)))"
        .parse::<Pattern<L>>()
        .unwrap();

    let vec4_pattern : Pattern<L> = "(Vec4 ?x ?y ?z ?w)"
        .parse::<Pattern<L>>()
        .unwrap();

    let add_mul_pattern : Pattern<L> = "(+ ?a (* ?b ?c))"
        .parse::<Pattern<L>>()
        .unwrap();

    let mul_pattern : Pattern<L> = "(* ?b ?c)"
        .parse::<Pattern<L>>()
        .unwrap();

    let zero_pattern : Pattern<L> = "0"
        .parse::<Pattern<L>>()
        .unwrap();

    MacSearcher {
        full_mac_pattern,
        vec4_pattern,
        add_mul_pattern,
        mul_pattern,
        zero_pattern,
    }
}

impl<L: Language, A: Analysis<L>> Searcher<L, A> for MacSearcher<L> {
    fn search_eclass(&self, egraph: &EGraph<L, A>, eclass: Id) -> Option<SearchMatches> {
        let vec4_matches = self.vec4_pattern.search_eclass(egraph, eclass);
        let vec4_mac_compatible = match vec4_matches {
            None => None,
            Some(matches) => {
                // Now we know the eclass is a Vec4. The question is: does it
                // match a pattern compatible with a MAC?
                // Either want:
                // (+ ?a (* ?b ?c))
                // (* ?b ?c)
                // 0
                let mut new_substs : Vec<Subst> = Vec::new();

                // TODO: do we need to do combinatorial madness across the
                // vector lanes?

                // For each set of substitutions
                for substs in matches.substs.iter() {
                    let mut new_sub = Subst::with_capacity(12);
                    let mut all_matches_found = true;
                    // For each variable x, y, x, w in (Vec4 ?x ?y ?z ?w)
                    for (i, vec4_var) in self.vec4_pattern.vars().iter().enumerate() {

                        // Check if that variable matches add/mul
                        let child_eclass = substs.get(*vec4_var).unwrap();
                        if let Some(add_mul_match) = self.add_mul_pattern.search_eclass(egraph, *child_eclass) {
                            for s in add_mul_match.substs.iter() {
                                for add_mul_var in self.add_mul_pattern.vars().iter() {
                                    let vs : String = format!("{}", *add_mul_var);
                                    let new_v = Var::from_str(&format!("{}{}", vs, i)).unwrap(); // Add post fix!!!
                                    new_sub.insert(new_v, *s.get(*add_mul_var).unwrap());
                                }
                            }
                        } else {
                            all_matches_found = false;
                            break;
                        }
                    }
                    if all_matches_found {
                        new_substs.push(new_sub);
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
        // self.full_mac_pattern.search_eclass(egraph, eclass)
        vec4_mac_compatible
    }

    fn vars(&self) -> Vec<Var> {
        self.full_mac_pattern.vars()
    }
}
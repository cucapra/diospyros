use egg::{*};

use std::str::FromStr;

use crate::{
    veclang::{VecLang},
    searchutils::*
};

#[derive(Debug, PartialEq, Clone)]
pub struct BinOpSearcher {
    pub left_var: String,
    pub right_var: String,
    pub full_pattern: Pattern<VecLang>,
    pub vec_pattern: Pattern<VecLang>,
    pub op_pattern: Pattern<VecLang>,
    pub zero_pattern: Pattern<VecLang>,
}

pub fn build_binop_searcher(op_str : &str) -> BinOpSearcher {
    let left_var = "a".to_string();
    let right_var = "b".to_string();
    let full_pattern = vec_fold_op(&op_str.to_string(), &left_var, &right_var)
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let vec_pattern = vec_with_op(&"Vec".to_string(), &"x".to_string())
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let op_pattern = format!("({} ?{} ?{})", op_str, left_var, right_var)
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let zero_pattern = "0"
        .parse::<Pattern<VecLang>>()
        .unwrap();

    BinOpSearcher {
        left_var,
        right_var,
        full_pattern,
        vec_pattern,
        op_pattern,
        zero_pattern,
    }
}

impl BinOpSearcher {
}

// We want each lane (?x0, ?x1, ?x2, ?x3) to match either:
//     (<binop> ?a ?b)
//     0               here, map ?a -> 0, ?b -> 0
impl<A: Analysis<VecLang>> Searcher<VecLang, A> for BinOpSearcher {
    fn search_eclass(&self, egraph: &EGraph<VecLang, A>, eclass: Id) -> Option<SearchMatches> {
        let vec_matches = self.vec_pattern.search_eclass(egraph, eclass);
        let vec_binop_compatible = match vec_matches {
            None => None,
            Some(matches) => {
                // Now we know the eclass is a Vec. The question is: does it
                // match a pattern compatible with this binary operation?
                let mut new_substs : Vec<Subst> = Vec::new();
                let zero_id = egraph.lookup(VecLang::Num(0)).unwrap();

                // For each set of substitutions
                for substs in matches.substs.iter() {
                    let mut all_matches_found = true;
                    let mut new_substs_options : Vec<Vec<Vec<(Var, Id)>>> = Vec::new();

                    // For each variable w, x, y, z in (Vec ?w ?x ?y ?z).
                    // We use the index i to disambiguate lanes, so we can have,
                    // for example, ?a0 through ?a3
                    for (i, vec_var) in self.vec_pattern.vars().iter().enumerate() {
                        // TODO: abstract this out to be prettier
                        let mut new_var_substs : Vec<Vec<(Var, Id)>> = Vec::new();

                        // Check if that variable matches the binop
                        let child_eclass = substs.get(*vec_var).unwrap();
                        if let Some(op_match) = self.op_pattern.search_eclass(egraph, *child_eclass) {
                            for s in op_match.substs.iter() {
                                let mut subs : Vec<(Var, Id)> = Vec::new();
                                for op_var in self.op_pattern.vars().iter() {
                                    let new_v = Var::from_str(&format!("{}{}", *op_var, i)).unwrap();
                                    subs.push((new_v, *s.get(*op_var).unwrap()));
                                }
                                new_var_substs.push(subs);
                            }
                        // This lane is just 0
                        } else if let Some(_) = self.zero_pattern.search_eclass(egraph, *child_eclass) {
                            // ?a and ?b  map to zero
                            let subs : Vec<(Var, Id)> = vec![
                                (Var::from_str(&format!("?a{}", i)).unwrap(), zero_id),
                                (Var::from_str(&format!("?b{}", i)).unwrap(), zero_id),
                            ];
                            new_var_substs.push(subs);

                        // This lane isn't compatible, so whole Vec not a match
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
        vec_binop_compatible
    }

    fn vars(&self) -> Vec<Var> {
        self.full_pattern.vars()
    }
}
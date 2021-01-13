use egg::{rewrite as rw, *};

use std::str::FromStr;

use crate::{searchutils::*, veclang::VecLang};

#[derive(Debug, PartialEq, Clone)]
pub struct BinOpSearcher {
    pub left_var: String,
    pub right_var: String,
    pub iden_var: Var,
    pub full_pattern: Pattern<VecLang>,
    pub vec_pattern: Pattern<VecLang>,
    pub op_pattern: Pattern<VecLang>,
    pub var_pattern: Pattern<VecLang>,
    pub left_iden: Option<i8>,
    pub right_iden: Option<i8>,
}

pub fn build_binop_rule(
    op_str: &str,
    vec_str: &str,
    left_iden: Option<i8>,
    right_iden: Option<i8>,
) -> Rewrite<VecLang, ()> {

    assert!(left_iden.is_some() || right_iden.is_some());

    let left_var = "a".to_string();
    let right_var = "b".to_string();
    let full_pattern = vec_fold_op(&op_str.to_string(), &left_var, &right_var)
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let vec_pattern = vec_with_var(&"x".to_string())
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let op_pattern = format!("({} ?{} ?{})", op_str, left_var, right_var)
        .parse::<Pattern<VecLang>>()
        .unwrap();

    let iden_var : Var = Var::from_str("?y").unwrap();
    let var_pattern = format!("{}", iden_var).parse::<Pattern<VecLang>>().unwrap();

    let applier: Pattern<VecLang> = format!(
        "({} {} {})",
        vec_str,
        vec_with_var(&left_var),
        vec_with_var(&right_var)
    )
    .parse()
    .unwrap();

    let searcher = BinOpSearcher {
        left_var,
        right_var,
        iden_var,
        full_pattern,
        vec_pattern,
        op_pattern,
        var_pattern,
        left_iden,
        right_iden,
    };

    rw!(format!("{}_binop_or_zero", op_str); { searcher } => { applier })
}

impl BinOpSearcher {}

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
                let mut new_substs: Vec<Subst> = Vec::new();

                let num_id = move |num| {
                    match num {
                        0 => egraph.lookup(VecLang::Num(0)).unwrap(),
                        1 => egraph.lookup(VecLang::Num(1)).unwrap(),
                        _ =>  panic!("Unexpected number for identity variable"),
                    }
                };

                // For each set of substitutions
                for substs in matches.substs.iter() {
                    let mut all_matches_found = true;
                    let mut iden_matches = 0;
                    let mut new_substs_options: Vec<Vec<Vec<(Var, Id)>>> = Vec::new();

                    // For each variable in (?x0, ?x1, ?x2, ?x3)
                    // We use the index i to disambiguate lanes, so we can have,
                    // for example, ?a0 through ?a3
                    for (i, vec_var) in self.vec_pattern.vars().iter().enumerate() {
                        // TODO: abstract this out to be prettier
                        let mut new_var_substs: Vec<Vec<(Var, Id)>> = Vec::new();

                        // Check if that variable matches the binop
                        let child_eclass = substs.get(*vec_var).unwrap();
                        if let Some(op_match) = self.op_pattern.search_eclass(egraph, *child_eclass)
                        {
                            for s in op_match.substs.iter() {
                                let mut subs: Vec<(Var, Id)> = Vec::new();
                                for op_var in self.op_pattern.vars().iter() {
                                    let new_v =
                                        Var::from_str(&format!("{}{}", *op_var, i)).unwrap();
                                    subs.push((new_v, *s.get(*op_var).unwrap()));
                                }
                                new_var_substs.push(subs);
                            }
                        // This lane is just some variable we can apply an identity on
                        } else if let Some(iden_match) = self
                            .var_pattern
                            .search_eclass(egraph, *child_eclass)
                        {
                            assert!(iden_match.substs.len() == 1);
                            iden_matches += 1;
                            if let Some(left) = self.left_iden {
                                // ?a maps to iden, ?b maps to the variable
                                let subs: Vec<(Var, Id)> = vec![
                                    (
                                        Var::from_str(&format!("?{}{}", self.left_var, i)).unwrap(),
                                        num_id(left),
                                    ),
                                    (
                                        Var::from_str(&format!("?{}{}", self.right_var, i)).unwrap(),
                                        *iden_match.substs.first().unwrap().get(self.iden_var).unwrap(),
                                    ),
                                ];
                                new_var_substs.push(subs);
                            }
                            if let Some(right) = self.right_iden {
                                // ?b maps to iden, ?a maps to the variable
                                let subs: Vec<(Var, Id)> = vec![
                                    (
                                        Var::from_str(&format!("?{}{}", self.right_var, i)).unwrap(),
                                        num_id(right),
                                    ),
                                    (
                                        Var::from_str(&format!("?{}{}", self.left_var, i)).unwrap(),
                                        *iden_match.substs.first().unwrap().get(self.iden_var).unwrap(),
                                    ),
                                ];
                                new_var_substs.push(subs);
                            }

                        // This lane isn't compatible, so whole Vec not a match
                        } else {
                            all_matches_found = false;
                            break;
                        }
                        new_substs_options.push(new_var_substs);
                    }
                    // Skip a match if every lane just matched on an identity
                    if all_matches_found && iden_matches < self.vec_pattern.vars().len() {
                        // Now there is at least one match, but we need to make
                        // potentially > 1 subst as children are combinatorial
                        let mut all_substs = all_matches_to_substs(&new_substs_options);
                        new_substs.append(&mut all_substs);
                    }
                }
                if new_substs.is_empty() {
                    None
                } else {
                    Some(SearchMatches {
                        eclass: matches.eclass,
                        substs: new_substs,
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

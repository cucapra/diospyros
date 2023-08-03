use crate::veclang::VecLang;
use egg::*;
use itertools::Itertools;

/// Search for permutations of sequences of Loads and Stores that are Aligned and Consecutive
///
/// This module creates an Applier, which attempts to find successful permutations of loads ands stores to be aligned and consecutive

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PermuteStore {
    pub a0: Var,
    pub a1: Var,
    pub a2: Var,
    pub a3: Var,
    pub b0: Var,
    pub b1: Var,
    pub b2: Var,
    pub b3: Var,
}

impl<A: Analysis<VecLang>> Applier<VecLang, A> for PermuteStore {
    /// We generate all permutations of the vecstore
    fn apply_one(&self, egraph: &mut EGraph<VecLang, A>, matched_id: Id, subst: &Subst) -> Vec<Id> {
        let a0_id: Id = subst[self.a0];
        let a1_id: Id = subst[self.a1];
        let a2_id: Id = subst[self.a2];
        let a3_id: Id = subst[self.a3];
        let base0_id: Id = subst[self.a0];
        let base1_id: Id = subst[self.a1];
        let base2_id: Id = subst[self.a2];
        let base3_id: Id = subst[self.a3];

        let original_list = vec![
            (a0_id, base0_id),
            (a1_id, base1_id),
            (a2_id, base2_id),
            (a3_id, base3_id),
        ];
        let perms = original_list.iter().permutations(4);
        let mut new_vec_stores = vec![];
        for perm in perms {
            let gep_vec_id = egraph.add(VecLang::Vec(
                vec![perm[0].0, perm[1].0, perm[2].0, perm[3].0].into_boxed_slice(),
            ));
            let vec_store_node =
                VecLang::VecStore([gep_vec_id, perm[0].1, perm[1].1, perm[2].1, perm[3].1]);
            let vec_store_id = egraph.add(vec_store_node);

            // add in the shuffle
            new_vec_stores.push(vec_store_id);
        }

        new_vec_stores
    }
}

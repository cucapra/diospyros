use crate::veclang::VecLang;
use egg::*;

/// Search for permutations of sequences of Loads and Stores that are Aligned and Consecutive
///
/// This module creates an Applier, which attempts to find successful permutations of loads ands stores to be aligned and consecutive

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PermuteLoad {
    pub a0: Var,
    pub a1: Var,
    pub a2: Var,
    pub a3: Var,
    pub b0: Var,
    pub b1: Var,
    pub b2: Var,
    pub b3: Var,
    pub o0: Var,
    pub o1: Var,
    pub o2: Var,
    pub o3: Var,
}

impl<A: Analysis<VecLang>> Applier<VecLang, A> for PermuteLoad {
    /// We are going to look for permutations of the four offsets that could
    /// allow for consecutive and aligned loading to occur with a shuffle operation
    fn apply_one(&self, egraph: &mut EGraph<VecLang, A>, matched_id: Id, subst: &Subst) -> Vec<Id> {
        let mut first_base = -10;
        for e in egraph[subst[self.b0]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                first_base = n;
            }
        }
        assert!(first_base != -10);
        let mut second_base = -10;
        for e in egraph[subst[self.b1]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                second_base = n;
            }
        }
        assert!(second_base != -10);
        let mut third_base = -10;
        for e in egraph[subst[self.b2]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                third_base = n;
            }
        }
        assert!(third_base != -10);
        let mut fourth_base = -10;
        for e in egraph[subst[self.b3]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                fourth_base = n;
            }
        }
        assert!(fourth_base != -10);

        if !(first_base == second_base
            && first_base == third_base
            && first_base == fourth_base
            && first_base >= 0)
        {
            return vec![];
        }

        let mut first_offset = -10;
        for e in egraph[subst[self.o0]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                first_offset = n;
            }
        }
        assert!(first_offset != -10);
        let mut second_offset = -10;
        for e in egraph[subst[self.o1]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                second_offset = n;
            }
        }
        assert!(second_offset != -10);
        let mut third_offset = -10;
        for e in egraph[subst[self.o2]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                third_offset = n;
            }
        }
        assert!(third_offset != -10);
        let mut fourth_offset = -10;
        for e in egraph[subst[self.o3]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                fourth_offset = n;
            }
        }
        assert!(fourth_offset != -10);

        let off0_id: Id = subst[self.o0];
        let off1_id: Id = subst[self.o1];
        let off2_id: Id = subst[self.o2];
        let off3_id: Id = subst[self.o3];
        let base0_id: Id = subst[self.a0];
        let base1_id: Id = subst[self.a1];
        let base2_id: Id = subst[self.a2];
        let base3_id: Id = subst[self.a3];

        // deduplicate
        let mut undedup_offsets = vec![first_offset, second_offset, third_offset, fourth_offset];
        undedup_offsets.dedup();
        if undedup_offsets.len() < 4 {
            return vec![];
        }

        let mut offsets: Vec<(i32, Id, Id)> = Vec::new();
        offsets.push((first_offset, off0_id, base0_id));
        offsets.push((second_offset, off1_id, base1_id));
        offsets.push((third_offset, off2_id, base2_id));
        offsets.push((fourth_offset, off3_id, base3_id));
        offsets.sort_by(|o1, o2| o1.0.partial_cmp(&o2.0).unwrap());

        if offsets[0].0 % 4 != 0 {
            return vec![];
        }

        if !(offsets[0].0 + 1 == offsets[1].0
            && offsets[0].0 + 2 == offsets[2].0
            && offsets[0].0 + 3 == offsets[3].0)
        {
            return vec![];
        }

        let mut shuffle_vec: Vec<u32> = Vec::new();
        let offset_ids_vec: Vec<Id> = vec![off0_id, off1_id, off2_id, off3_id];
        for off_id in offset_ids_vec {
            for (i, (_, other_off_id, _)) in offsets.iter().enumerate() {
                if off_id == *other_off_id {
                    shuffle_vec.push(i as u32);
                }
            }
        }
        // the identity permutation does not count, as it gets handled elsewhere
        if shuffle_vec == vec![0, 1, 2, 3] {
            return vec![];
        }

        let mut shuffle_ids_vec: Vec<Id> = Vec::new();
        for elt in shuffle_vec {
            let new_shuf_id = egraph.add(VecLang::Num(elt as i32));
            shuffle_ids_vec.push(new_shuf_id);
        }
        let (_, _, first_base_id) = offsets[0];
        let aligned_consec_load_vec = egraph.add(VecLang::AlignedConsecVecLoad([first_base_id]));
        let shuffle_shuf_arg = egraph.add(VecLang::DataVec(shuffle_ids_vec.into_boxed_slice()));
        let shuffle_vec_op = egraph.add(VecLang::Shuffle([
            aligned_consec_load_vec,
            shuffle_shuf_arg,
        ]));

        vec![shuffle_vec_op]
    }
}

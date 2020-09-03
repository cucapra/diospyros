use egg::{*};

use crate::{
    config::*
};

pub fn vec_with_op(op: &String, pre: &String) -> String {
    let joined = ids_with_prefix(pre, vector_width()).join(" ");
    format!("({} {})", op, joined)
}

pub fn vec_with_var(pre: &String) -> String {
    vec_with_op(&"Vec".to_string(), pre)
}

pub fn vec_fold_op(op: &String, pre_left: &String, pre_right: &String) -> String {
    let mut ops : Vec<String> = Vec::with_capacity(vector_width());
    for i in 0..vector_width() {
        ops.push(format!("({} ?{}{} ?{}{})", op, pre_left, i, pre_right, i))
    }
    let joined = ops.join(" ");
    format!("(Vec {})", joined)
}

pub fn vec_map_op(op: &String, pre: &String) -> String {
    let mut ops : Vec<String> = Vec::with_capacity(vector_width());
    for i in 0..vector_width() {
        ops.push(format!("({} ?{}{})", op, pre, i))
    }
    let joined = ops.join(" ");
    format!("(Vec {})", joined)
}

pub fn ids_with_prefix(pre: &String, count: usize) -> Vec<String> {
    let mut ids : Vec<String> = Vec::with_capacity(count);
    for i in 0..count {
        ids.push(format!("?{}{}", pre, i))
    }
    ids
}

// Combinatorial combination of match children
pub fn all_matches_to_substs(all_matches: &[Vec<Vec<(Var, Id)>>]) -> Vec<Subst> {
    match all_matches.first() {
        None => vec![Subst::with_capacity(12)],
        Some(var_substs) => {
            let mut new_substs : Vec<Subst> = Vec::new();
            let substs = all_matches_to_substs(&all_matches[1..]);
            for var_match in var_substs.iter() {
                for sub in &substs {
                    let mut sub_clone = sub.clone();
                    for (var, id) in var_match.iter() {
                        sub_clone.insert(*var, *id);
                    }
                    new_substs.push(sub_clone);
                }
            }
            new_substs
        }
    }
}
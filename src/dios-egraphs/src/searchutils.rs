use egg::{*};

pub fn ids_with_prefix(pre : String, count: usize) -> Vec<String> {
    let mut ids : Vec<String> = Vec::with_capacity(count);
    for i in 0..count {
        ids.push(format!("{}{}", pre, i))
    }
    println!("{:?}", ids);
    ids
}

// Combinatorial combination of match children
pub fn all_matches_to_substs(all_matches : &[Vec<Vec<(Var, Id)>>]) -> Vec<Subst> {
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
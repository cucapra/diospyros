use egg::{rewrite as rw, *};

use crate::{
    veclang::{EGraph, VecLang},
};

fn is_all_same_memory(vars: &[&'static str]) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
    let vars: Vec<Var> = vars.iter().map(|v| v.parse().unwrap()).collect();
    println!("{:?}", vars);
    move |egraph, _, subst| {

        let init_get_matches = egraph[subst[vars[0]]]
            .nodes
            .iter()
            .filter(|n| matches!(n, VecLang::Get(..)));

        for m in init_get_matches {
            if let VecLang::Get(v) = m {
                // println!("{:?}", egraph[v[0]]);
            }
        }

        vars.iter().all(|v| {
            let get_matches = egraph[subst[*v]]
                .nodes
                .iter()
                .filter(|n| matches!(n, VecLang::Get(..)));
            // TODO: check that there is some match in get_match and init_get_matches
            false
        })
    }
}

pub fn rules() -> Vec<Rewrite<VecLang, ()>> {
    let mut rules: Vec<Rewrite<VecLang, ()>> = vec![
        rw!("commute-add"; "(+ ?a ?b)" => "(+ ?b ?a)"),
        rw!("commute-mul"; "(* ?a ?b)" => "(* ?b ?a)"),
        rw!("assoc-add-1"; "(+ ?a ?b ?c)" => "(+ ?a (+ ?b ?c))"),
        rw!("assoc-add-2"; "(+ ?a ?b ?c)" => "(+ (+ ?a ?b) ?c)"),
        rw!("assoc-mul-1"; "(* ?a ?b ?c)" => "(* ?a (* ?b ?c))"),
        rw!("assoc-mul-2"; "(* ?a ?b ?c)" => "(* (* ?a ?b) ?c))"),
        rw!("mul-0"; "(* ?a 0)" => "0"),
        rw!("mul-1"; "(* ?a 1)" => "?a"),

        // Allow hallucination of 0's to allow pattern matching larger vectors
        rw!("zero-1"; "?a" => "(+ ?a 0)"),
        rw!("zero-2"; "0" => "(* 0 0)"),

        rw!("litvec"; "(Vec4 ?a ?b ?c ?d)"
            => "(LitVec4 ?a ?b ?c ?d)" if is_all_same_memory(&["?a", "?b", "?c", "?d"])),

        // Partition lists - hardcoded
        rw!("partition-1"; "(List ?a)"
            => "(Vec4 ?a 0 0 0)"),
        rw!("partition-2"; "(List ?a ?b)"
            => "(Vec4 ?a ?b 0 0)"),
        rw!("partition-3"; "(List ?a ?b ?c)"
            => "(Vec4 ?a ?b ?c 0)"),
        rw!("partition-4"; "(List ?a ?b ?c ?d)"
            => "(Vec4 ?a ?b ?c ?d)"),
        rw!("partition-5"; "(List ?a ?b ?c ?d ?e)"
            => "(Concat (Vec4 ?a ?b ?c ?d) (Vec4 ?e 0 0 0))"),
        rw!("partition-6"; "(List ?a ?b ?c ?d ?e ?f)"
            => "(Concat (Vec4 ?a ?b ?c ?d) (Vec4 ?e ?f 0 0))"),
        rw!("partition-7"; "(List ?a ?b ?c ?d ?e ?f ?g)"
            => "(Concat (Vec4 ?a ?b ?c ?d) (Vec4 ?e ?f ?g 0))"),
        rw!("partition-8"; "(List ?a ?b ?c ?d ?e ?f ?g ?h)"
            => "(Concat (Vec4 ?a ?b ?c ?d) (Vec4 ?e ?f ?g ?h))"),

        rw!("partition-9"; "(List ?v0 ?v1 ?v2 ?v3 ?v4 ?v5 ?v6 ?v7 ?v8)"
            => "(Concat (Vec4 ?v0 ?v1 ?v2 ?v3)
                        (Concat (Vec4 ?v4 ?v5 ?v6 ?v7)
                                (Vec4 ?v8 0 0 0)))"),

        // For now, hardcode vectors with 2-4 lanes
        rw!("vec-add-2"; "(Vec4 (+ ?a ?b) (+ ?c ?d) 0 0)"
            => "(VecAdd (Vec4 ?a ?c 0 0) (Vec4 ?b ?d 0 0))"),
        rw!("vec-add-3"; "(Vec4 (+ ?a ?b) (+ ?c ?d) (+ ?e ?f) 0)"
            => "(VecAdd (Vec4 ?a ?c ?e 0) (Vec4 ?b ?d ?f 0))"),
        rw!("vec-add-4"; "(Vec4 (+ ?a ?b) (+ ?c ?d) (+ ?e ?f) (+ ?g ?h))"
            => "(VecAdd (Vec4 ?a ?c ?e ?g) (Vec4 ?b ?d ?f ?h))"),

        // For now, hardcode vectors with 2-4 lanes
        rw!("vec-mul-2"; "(Vec4 (* ?a ?b) (* ?c ?d) 0 0)"
            => "(VecMul (Vec4 ?a ?c 0 0) (Vec4 ?b ?d 0 0))"),
        rw!("vec-mul-3"; "(Vec4 (* ?a ?b) (* ?c ?d) (* ?e ?f) 0)"
            => "(VecMul (Vec4 ?a ?c ?e 0) (Vec4 ?b ?d ?f 0))"),
        rw!("vec-mul-4"; "(Vec4 (* ?a ?b) (* ?c ?d) (* ?e ?f) (* ?g ?h))"
            => "(VecMul (Vec4 ?a ?c ?e ?g) (Vec4 ?b ?d ?f ?h))"),

        // For now, hardcode vectors with 2-4 lanes
        rw!("vec-mac-2"; "(Vec4 (+ ?a (* ?b ?c))
                                (+ ?d (* ?e ?f))
                                0
                                0)"
            => "(VecMAC (Vec4 ?a ?d 0 0)
                        (Vec4 ?b ?e 0 0)
                        (Vec4 ?c ?f 0 0))"),
        rw!("vec-mac-3"; "(Vec4 (+ ?a (* ?b ?c))
                                (+ ?d (* ?e ?f))
                                (+ ?g (* ?h ?i))
                                0)"
            => "(VecMAC (Vec4 ?a ?d ?g 0)
                        (Vec4 ?b ?e ?h 0)
                        (Vec4 ?c ?f ?i 0))"),
        rw!("vec-mac-4"; "(Vec4 (+ ?a (* ?b ?c))
                                (+ ?d (* ?e ?f))
                                (+ ?g (* ?h ?i))
                                (+ ?j (* ?k ?l)))"
            => "(VecMAC (Vec4 ?a ?d ?g ?j)
                        (Vec4 ?b ?e ?h ?k)
                        (Vec4 ?c ?f ?i ?l))"),
    ];

    rules.extend(vec![
        // Very expensive rules to allow more hallucination of zeros
        rw!("add-0"; "(+ ?a 0)" <=> "?a"),
        rw!("add-1"; "(+ ?a 0 0)" <=> "?a"),
        rw!("add-2"; "(+ ?a 0 0 0)" <=> "?a"),
        rw!("add-3"; "(+ ?a ?b 0 0)" <=> "(+ ?a ?b)"),

        rw!("add-4"; "(+ ?a ?b ?c)" <=> "(+ ?a (+ ?b ?c))"),
        rw!("add-5"; "(+ ?a ?b ?c ?d)" <=> "(+ ?a (+ ?b (+ ?c ?d)))"),
    ].concat());
    return rules;
}
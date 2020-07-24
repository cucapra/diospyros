use egg::{rewrite as rw, *};

use itertools::Itertools;

use crate::{
    veclang::{EGraph, VecLang},
    cost::VecCostFn,
    macsearcher::build_mac_searcher
};

// Check if all the variables, in this case memories, are equivalent
fn is_all_same_memory(vars: &[&'static str]) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
    let vars: Vec<Var> = vars.iter().map(|v| v.parse().unwrap()).collect();
    let zero = VecLang::Num(0);
    move |egraph, _, subst| {
        let non_zero_gets = vars.iter().filter(|v| {
            !egraph[subst[**v]].nodes.contains(&zero)
        }).unique_by(|v| {egraph.find(subst[**v])});
        non_zero_gets.collect::<Vec<_>>().len() < 2
    }
}

/// Run the rewrite rules over the input program and return the best (cost, program)
pub fn run(prog: &RecExpr<VecLang>) -> (f64, RecExpr<VecLang>) {
    let rules = rules();
    let runner = Runner::default()
        .with_expr(&prog)
        .with_node_limit(900_000)
        .with_time_limit(std::time::Duration::from_secs(120))
        .with_iter_limit(60)
        .run(&rules);

    // print reason to STDERR.
    eprintln!(
        "Stopped after {} iterations, reason: {:?}",
        runner.iterations.len(),
        runner.stop_reason
    );

    let (eg, root) = (runner.egraph, runner.roots[0]);

    let mut extractor = Extractor::new(&eg, VecCostFn { egraph: &eg });
    extractor.find_best(root)
}

pub fn rules() -> Vec<Rewrite<VecLang, ()>> {
    let mac_searcher = build_mac_searcher();
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

        rw!("expand-zero-get"; "0" => "(Get 0 0)"),
        rw!("litvec"; "(Vec4 (Get ?a ?i) (Get ?b ?j) (Get ?c ?k) (Get ?d ?l))"
            => "(LitVec4 (Get ?a ?i) (Get ?b ?j) (Get ?c ?k) (Get ?d ?l))"
            if is_all_same_memory(&["?a", "?b", "?c", "?d"])),

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
        // Either want:
        // (+ ?a (* ?b ?c))
        // (* ?b ?c)
        // 0
        rw!("vec-mac-3"; "(Vec4 (+ ?a (* ?b ?c))
                                (+ ?d (* ?e ?f))
                                (+ ?g (* ?h ?i))
                                0)"
            => "(VecMAC (Vec4 ?a ?d ?g 0)
                        (Vec4 ?b ?e ?h 0)
                        (Vec4 ?c ?f ?i 0))"),

        rw!("vec-mac-4"; mac_searcher
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

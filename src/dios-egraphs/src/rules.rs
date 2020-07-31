use egg::{rewrite as rw, *};

use itertools::Itertools;

use crate::{
    veclang::{EGraph, VecLang},
    cost::VecCostFn,
    macsearcher::build_mac_searcher,
    binopsearcher::build_binop_searcher
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
pub fn run(prog: &RecExpr<VecLang>, timeout: u64) -> (f64, RecExpr<VecLang>) {
    let rules = rules();
    let mut init_eg : EGraph = EGraph::new(());
    init_eg.add(VecLang::Num(0));
    let runner = Runner::default()
        .with_egraph(init_eg)
        .with_expr(&prog)
        .with_node_limit(10_000_000)
        .with_time_limit(std::time::Duration::from_secs(timeout))
        .with_iter_limit(10_000)
        .run(&rules);

    // print reason to STDERR.
    eprintln!(
        "Stopped after {} iterations, reason: {:?}",
        runner.iterations.len(),
        runner.stop_reason
    );

    let (eg, root) = (runner.egraph, runner.roots[0]);

    // Always add the literal zero
    let mut extractor = Extractor::new(&eg, VecCostFn { egraph: &eg });
    extractor.find_best(root)
}

pub fn rules() -> Vec<Rewrite<VecLang, ()>> {
    let rules: Vec<Rewrite<VecLang, ()>> = vec![
        // Basic associativity/commutativity/identities
        rw!("commute-add"; "(+ ?a ?b)" => "(+ ?b ?a)"),
        rw!("commute-mul"; "(* ?a ?b)" => "(* ?b ?a)"),
        rw!("assoc-add"; "(+ (+ ?a ?b) ?c)" => "(+ ?a (+ ?b ?c))"),
        rw!("assoc-mul"; "(* (* ?a ?b) ?c)" => "(* ?a (* ?b ?c))"),
        rw!("add-0"; "(+ ?a 0)" => "?a"),
        rw!("mul-0"; "(* ?a 0)" => "0"),
        rw!("mul-1"; "(* ?a 1)" => "?a"),

        // Variadic to nesting - hard coded
        rw!("add-variadic-3"; "(+ ?a ?b ?c)" => "(+ ?a (+ ?b ?c))"),
        rw!("add-variadic-4"; "(+ ?a ?b ?c ?d)" => "(+ ?a (+ ?b (+ ?c ?d)))"),
        rw!("add-variadic-5"; "(+ ?a ?b ?c ?d ?e)" =>
            "(+ ?a (+ ?b (+ ?c (+ ?d ?e))))"),
        rw!("add-variadic-6"; "(+ ?a ?b ?c ?d ?e ?f)" =>
            "(+ ?a (+ ?b (+ ?c (+ ?d (+ ?e ?f)))))"),
        rw!("add-variadic-7"; "(+ ?a ?b ?c ?d ?e ?f ?g)" =>
            "(+ ?a (+ ?b (+ ?c (+ ?d (+ ?e (+ ?f ?g))))))"),
        rw!("add-variadic-8"; "(+ ?a ?b ?c ?d ?e ?f ?g ?h)" =>
            "(+ ?a (+ ?b (+ ?c (+ ?d (+ ?e (+ ?f (+ ?g ?h)))))))"),
        rw!("add-variadic-9"; "(+ ?a ?b ?c ?d ?e ?f ?g ?h ?i)" =>
            "(+ ?a (+ ?b (+ ?c (+ ?d (+ ?e (+ ?f (+ ?g (+ ?h ?i))))))))"),

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

        // Custom searchers for vector ops
        rw!("vec-add"; { build_binop_searcher("+") }
            => "(VecAdd (Vec4 ?a0 ?a1 ?a2 ?a3)
                        (Vec4 ?b0 ?b1 ?b2 ?b3))"),

        rw!("vec-mul"; { build_binop_searcher("*") }
            => "(VecMul (Vec4 ?a0 ?a1 ?a2 ?a3)
                        (Vec4 ?b0 ?b1 ?b2 ?b3))"),

        rw!("vec-mac"; { build_mac_searcher() }
            => "(VecMAC (Vec4 ?a0 ?a1 ?a2 ?a3)
                        (Vec4 ?b0 ?b1 ?b2 ?b3)
                        (Vec4 ?c0 ?c1 ?c2 ?c3))"),
    ];
    return rules;
}

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
        non_zero_gets.count() < 2
    }
}

/// Run the rewrite rules over the input program and return the best (cost, program)
pub fn run(prog: &RecExpr<VecLang>, timeout: u64, no_ac: bool) -> (f64, RecExpr<VecLang>) {
    let rules = rules(no_ac);
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

pub fn rules(no_ac: bool) -> Vec<Rewrite<VecLang, ()>> {
    let mut rules: Vec<Rewrite<VecLang, ()>> = vec![
        rw!("add-0"; "(+ 0 ?a)" => "?a"),
        rw!("mul-0"; "(* 0 ?a)" => "0"),
        rw!("mul-1"; "(* 1 ?a)" => "?a"),
        rw!("div-1"; "(/ ?a 1)" => "?a"),

        rw!("add-0-inv"; "?a" => "(+ 0 ?a)"),
        rw!("mul-1-inv"; "?a" => "(* 1 ?a)"),
        rw!("div-1-inv"; "?a" => "(/ ?a 1)"),

        rw!("neg-zero-inv"; "0" => "(neg 0)"),
        rw!("sqrt-1-inv"; "1" => "(sqrt 1)"),

        // Sign and negate
        rw!("neg-sgn"; "(neg (sgn ?a))" => "(sgn (neg ?a))"),


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

        // Custom searchers for vector ops
        rw!("vec-neg"; "(Vec4 (neg ?a0) (neg ?a1) (neg ?a2) (neg ?a3))"
            => "(VecNeg (Vec4 ?a0 ?a1 ?a2 ?a3))"),
        rw!("vec-sqrt"; "(Vec4 (sqrt ?a0) (sqrt ?a1) (sqrt ?a2) (sqrt ?a3))"
            => "(VecSqrt (Vec4 ?a0 ?a1 ?a2 ?a3))"),
        rw!("vec-sgn"; "(Vec4 (sgn ?a0) (sgn ?a1) (sgn ?a2) (sgn ?a3))"
            => "(VecSgn (Vec4 ?a0 ?a1 ?a2 ?a3))"),

        rw!("vec-div"; "(Vec4 (/ ?a0 ?b0)
                              (/ ?a1 ?b1)
                              (/ ?a2 ?b2)
                              (/ ?a3 ?b3))"

            => "(VecDiv (Vec4 ?a0 ?a1 ?a2 ?a3)
                        (Vec4 ?b0 ?b1 ?b2 ?b3))"),

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

    if !no_ac {
        rules.extend(vec![
            //  Basic associativity/commutativity/identities
            rw!("commute-add"; "(+ ?a ?b)" => "(+ ?b ?a)"),
            rw!("commute-mul"; "(* ?a ?b)" => "(* ?b ?a)"),
            rw!("assoc-add"; "(+ (+ ?a ?b) ?c)" => "(+ ?a (+ ?b ?c))"),
            rw!("assoc-mul"; "(* (* ?a ?b) ?c)" => "(* ?a (* ?b ?c))"),
        ]);
    }
    rules
}

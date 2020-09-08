use egg::{rewrite as rw, *};

use itertools::Itertools;

use crate::{
    veclang::{EGraph, VecLang},
    cost::VecCostFn,
    macsearcher::build_mac_rule,
    binopsearcher::build_binop_or_zero_rule,
    searchutils::*,
    config::*
};

// Check if all the variables, in this case memories, are equivalent
fn is_all_same_memory_or_zero(vars: &Vec<String>) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
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

pub fn build_binop_rule(op_str : &str, vec_str : &str) -> Rewrite<VecLang, ()> {
    let searcher: Pattern<VecLang> = vec_fold_op(&op_str.to_string(), &"a".to_string(), &"b".to_string())
        .parse()
        .unwrap();

    let applier: Pattern<VecLang> = format!("({} {} {})",
        vec_str,
        vec_with_var(&"a".to_string()),
        vec_with_var(&"b".to_string()))
        .parse()
        .unwrap();

    rw!(format!("{}_binop", op_str); { searcher } => { applier })
}

pub fn build_unop_rule(op_str : &str, vec_str : &str) -> Rewrite<VecLang, ()> {
    let searcher: Pattern<VecLang> = vec_map_op(&op_str.to_string(), &"a".to_string())
        .parse()
        .unwrap();
    let applier: Pattern<VecLang> = format!("({} {})",
        vec_str,
        vec_with_var(&"a".to_string()))
        .parse()
        .unwrap();

    rw!(format!("{}_unop", op_str); { searcher } => { applier })
}

pub fn build_litvec_rule() -> Rewrite<VecLang, ()> {
    let mem_vars = ids_with_prefix(&"a".to_string(), vector_width());
    let mut gets : Vec<String> = Vec::with_capacity(vector_width());
    for i in 0..vector_width() {
        gets.push(format!("(Get {} ?{}{})", mem_vars[i], "i", i))
    }
    let all_gets = gets.join(" ");

    let searcher: Pattern<VecLang> = format!("(Vec {})", all_gets)
        .parse()
        .unwrap();

    let applier: Pattern<VecLang> = format!("(LitVec {})", all_gets)
        .parse()
        .unwrap();

    rw!("litvec"; { searcher } => { applier }
        if is_all_same_memory_or_zero(&mem_vars))
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

        rw!("expand-zero-get"; "0" => "(Get 0 0)"),

        rw!("vec-mac-add-mul";
            "(VecAdd ?v0 (VecMul ?v1 ?v2))"
            => "(VecMAC ?v0 ?v1 ?v2)"),

        // Literal vectors, that use the same memory or no memory in every lane,
        // are cheaper
        build_litvec_rule(),

        // Custom searchers for vector ops
        build_unop_rule("neg", "VecNeg"),
        build_unop_rule("sqrt", "VecSqrt"),
        build_unop_rule("sgn", "VecSgn"),

        build_binop_rule("/", "VecDiv"),

        build_binop_or_zero_rule("+", "VecAdd"),
        build_binop_or_zero_rule("*", "VecMul"),

        build_mac_rule(),
    ];

    // Bidirectional rules
    rules.extend(vec![
        // Sign and negate
        rw!("neg-neg"; "(neg (neg ?a))" <=> "?a"),
        rw!("neg-sgn"; "(neg (sgn ?a))" <=> "(sgn (neg ?a))"),
        rw!("neg-zero-inv"; "0" <=> "(neg 0)"),
        rw!("sqrt-1-inv"; "1" <=> "(sqrt 1)"),
    ].concat());

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

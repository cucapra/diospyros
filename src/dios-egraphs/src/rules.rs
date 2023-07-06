use egg::{rewrite as rw, *};

use itertools::Itertools;

use crate::{
    alignconsecsearcher::*,
    binopsearcher::build_binop_or_zero_rule,
    config::*,
    cost::VecCostFn,
    macsearcher::build_mac_rule,
    permutestore::*,
    searchutils::*,
    veclang::{EGraph, VecLang},
};

// Check if all the variables, in this case memories, are equivalent
fn is_all_same_memory_or_zero(vars: &Vec<String>) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
    let vars: Vec<Var> = vars.iter().map(|v| v.parse().unwrap()).collect();
    let zero = VecLang::Num(0);
    move |egraph, _, subst| {
        let non_zero_gets = vars
            .iter()
            .filter(|v| !egraph[subst[**v]].nodes.contains(&zero))
            .unique_by(|v| egraph.find(subst[**v]));
        non_zero_gets.count() < 2
    }
}

fn filter_applicable_rules(rules: &mut Vec<Rewrite<VecLang, ()>>, prog: &RecExpr<VecLang>) {
    let prog_str: String = prog.pretty(80);
    let ops_to_filter = vec!["neg", "sqrt", "/"];
    let unused_ops: Vec<&&str> = ops_to_filter
        .iter()
        .filter(|&op| !prog_str.contains(op))
        .collect();

    let mut dropped = "".to_string();
    rules.retain(|r| {
        let drop = unused_ops.iter().any(|&op| {
            let rule_sr = format!("{:?}", r);
            rule_sr.contains(op)
        });
        if drop {
            dropped = format!("{} {}", dropped, r.name())
        };
        !drop
    });
    if dropped != "" {
        eprintln!("Dropping inapplicable rules:{}", dropped);
    }
}

/// Run the rewrite rules over the input program and return the best (cost, program)
pub fn run(
    prog: &RecExpr<VecLang>,
    timeout: u64,
    no_ac: bool,
    no_vec: bool,
) -> (f64, RecExpr<VecLang>) {
    let mut rules = rules(no_ac, no_vec);
    filter_applicable_rules(&mut rules, prog);
    let mut init_eg: EGraph = EGraph::new(());
    init_eg.add(VecLang::Num(0));
    let runner = Runner::default()
        .with_egraph(init_eg)
        .with_expr(&prog)
        .with_node_limit(10_000_000)
        .with_time_limit(std::time::Duration::from_secs(timeout))
        .with_iter_limit(10_000)
        .run(&rules);

    // print reason to STDERR
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

pub fn build_binop_rule(op_str: &str, vec_str: &str) -> Rewrite<VecLang, ()> {
    let searcher: Pattern<VecLang> =
        vec_fold_op(&op_str.to_string(), &"a".to_string(), &"b".to_string())
            .parse()
            .unwrap();

    let applier: Pattern<VecLang> = format!(
        "({} {} {})",
        vec_str,
        vec_with_var(&"a".to_string()),
        vec_with_var(&"b".to_string())
    )
    .parse()
    .unwrap();

    rw!(format!("{}_binop", op_str); { searcher } => { applier })
}

pub fn build_unop_rule(op_str: &str, vec_str: &str) -> Rewrite<VecLang, ()> {
    let searcher: Pattern<VecLang> = vec_map_op(&op_str.to_string(), &"a".to_string())
        .parse()
        .unwrap();
    let applier: Pattern<VecLang> = format!("({} {})", vec_str, vec_with_var(&"a".to_string()))
        .parse()
        .unwrap();

    rw!(format!("{}_unop", op_str); { searcher } => { applier })
}

pub fn build_litvec_rule() -> Rewrite<VecLang, ()> {
    let mem_vars = ids_with_prefix(&"a".to_string(), vector_width());
    let mut gets: Vec<String> = Vec::with_capacity(vector_width());
    for i in 0..vector_width() {
        gets.push(format!("(Get {} ?{}{})", mem_vars[i], "i", i))
    }
    let all_gets = gets.join(" ");

    let searcher: Pattern<VecLang> = format!("(Vec {})", all_gets).parse().unwrap();

    let applier: Pattern<VecLang> = format!("(LitVec {})", all_gets).parse().unwrap();

    rw!("litvec"; { searcher } => { applier }
        if is_all_same_memory_or_zero(&mem_vars))
}

fn memory_is_aligned_and_consec2(
    var1: &'static str,
    var2: &'static str,
    var3: &'static str,
    var4: &'static str,
) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
    let var1: Var = var1.parse().unwrap();
    let var2: Var = var2.parse().unwrap();
    let var3: Var = var3.parse().unwrap();
    let var4: Var = var4.parse().unwrap();
    move |egraph, _, subst| unsafe {
        let mut first_base = -10;
        for e in egraph[subst[var1]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                first_base = n;
            }
        }
        assert!(first_base != -10);
        let mut second_base = -10;
        for e in egraph[subst[var2]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                second_base = n;
            }
        }
        assert!(second_base != -10);

        if !(first_base == second_base) {
            return false;
        }

        let mut first_offset = -10;
        for e in egraph[subst[var3]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                first_offset = n;
            }
        }
        assert!(first_offset != -10);
        let mut second_offset = -10;
        for e in egraph[subst[var4]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                second_offset = n;
            }
        }
        assert!(second_offset != -10);

        if !(first_offset + 1 == second_offset) {
            return false;
        }
        if !(first_offset % 4 == 0) {
            return false;
        }

        return true;
    }
}

// This returns a function that implements Condition
fn memory_is_aligned_and_consec(
    var1: &'static str,
    var2: &'static str,
    var3: &'static str,
    var4: &'static str,
    var5: &'static str,
    var6: &'static str,
    var7: &'static str,
    var8: &'static str,
) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
    let var1: Var = var1.parse().unwrap();
    let var2: Var = var2.parse().unwrap();
    let var3: Var = var3.parse().unwrap();
    let var4: Var = var4.parse().unwrap();
    let var5: Var = var5.parse().unwrap();
    let var6: Var = var6.parse().unwrap();
    let var7: Var = var7.parse().unwrap();
    let var8: Var = var8.parse().unwrap();
    move |egraph, _, subst| unsafe {
        let mut first_base = -10;
        for e in egraph[subst[var1]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                first_base = n;
            }
        }
        assert!(first_base != -10);
        let mut second_base = -10;
        for e in egraph[subst[var2]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                second_base = n;
            }
        }
        assert!(second_base != -10);
        let mut third_base = -10;
        for e in egraph[subst[var3]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                third_base = n;
            }
        }
        assert!(third_base != -10);
        let mut fourth_base = -10;
        for e in egraph[subst[var4]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                fourth_base = n;
            }
        }
        assert!(fourth_base != -10);

        if !(first_base == second_base && first_base == third_base && first_base == fourth_base) {
            return false;
        }

        let mut first_offset = -10;
        for e in egraph[subst[var5]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                first_offset = n;
            }
        }
        assert!(first_offset != -10);
        let mut second_offset = -10;
        for e in egraph[subst[var6]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                second_offset = n;
            }
        }
        assert!(second_offset != -10);
        let mut third_offset = -10;
        for e in egraph[subst[var7]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                third_offset = n;
            }
        }
        assert!(third_offset != -10);
        let mut fourth_offset = -10;
        for e in egraph[subst[var8]].nodes.as_slice().into_iter() {
            if let VecLang::Num(n) = *e {
                fourth_offset = n;
            }
        }
        assert!(fourth_offset != -10);

        if !(first_offset + 1 == second_offset
            && first_offset + 2 == third_offset
            && first_offset + 3 == fourth_offset)
        {
            return false;
        }
        if !(first_offset % 4 == 0) {
            return false;
        }

        return true;
    }
}

pub fn rules(no_ac: bool, no_vec: bool) -> Vec<Rewrite<VecLang, ()>> {
    let mut rules: Vec<Rewrite<VecLang, ()>> = vec![
        rw!("add-0"; "(+ 0 ?a)" => "?a"),
        rw!("mul-0"; "(* 0 ?a)" => "0"),
        rw!("mul-1"; "(* 1 ?a)" => "?a"),
        rw!("div-1"; "(/ ?a 1)" => "?a"),
        rw!("add-0-inv"; "?a" => "(+ 0 ?a)"),
        rw!("mul-1-inv"; "?a" => "(* 1 ?a)"),
        rw!("div-1-inv"; "?a" => "(/ ?a 1)"),
        rw!("expand-zero-get"; "0" => "(Get 0 0)"),
        // Literal vectors, that use the same memory or no memory in every lane,
        // are cheaper
        build_litvec_rule(),
    ];

    // Bidirectional rules
    rules.extend(
        vec![
            // Sign and negate
            rw!("neg-neg"; "(neg (neg ?a))" <=> "?a"),
            rw!("neg-sgn"; "(neg (sgn ?a))" <=> "(sgn (neg ?a))"),
            rw!("neg-zero-inv"; "0" <=> "(neg 0)"),
            rw!("neg-minus"; "(neg ?a)" <=> "(- 0 ?a)"),
            rw!("neg-minus-zero"; "(neg ?a)" <=> "(- 0 ?a)"),
            rw!("sqrt-1-inv"; "1" <=> "(sqrt 1)"),
        ]
        .concat(),
    );

    // Vector rules
    if !no_vec {
        rules.extend(vec![
            // Aligned Consec Load rule
            rw!("vec-load-aligned-consec"; "(Vec (Load ?a0 ?b0 ?o0) (Load ?a1 ?b1 ?o1) (Load ?a2 ?b2 ?o2) (Load ?a3 ?b3 ?o3))" => "(AlignedConsecVecLoad ?a0)" if memory_is_aligned_and_consec("?b0", "?b1", "?b2", "?b3", "?o0", "?o1", "?o2", "?o3")),
            // Load load fusion rule
            rw!("vec-load-loads"; "(Vec (Load ?a0 ?b0 ?o0) (Load ?a1 ?b1 ?o1) (Load ?a2 ?b2 ?o2) (Load ?a3 ?b3 ?o3))" => "(VecLoad ?a0 ?a1 ?a2 ?a3 (DataVec ?b0 ?b1 ?b2 ?b3) (DataVec ?o0 ?o1 ?o2 ?o3))"),
            // Set store fusion rule
            rw!("vec-store-sets"; "(Vec (Store ?a0 ?b0) (Store ?a1 ?b1) (Store ?a2 ?b2) (Store ?a3 ?b3))" => "(VecStore (Vec ?a0 ?a1 ?a2 ?a3) ?b0 ?b1 ?b2 ?b3)"),

            // rw!("vec-store-permutations"; "(VecStore (Vec ?a0 ?a1 ?a2 ?a3) ?b0 ?b1 ?b2 ?b3)" => { PermuteStore {
            //     a0: "?a0".parse().unwrap(),
            //     a1: "?a1".parse().unwrap(),
            //     a2: "?a2".parse().unwrap(),
            //     a3: "?a3".parse().unwrap(),
            //     b0: "?b0".parse().unwrap(),
            //     b1: "?b1".parse().unwrap(),
            //     b2: "?b2".parse().unwrap(),
            //     b3: "?b3".parse().unwrap(),
            // }}),

            // also should have split for into vecstore2 as well

            // Special MAC fusion rule
            // rw!("vec-mac-add-mul";
            //     "(VecAdd ?v0 (VecMul ?v1 ?v2))"
            //     => "(VecMAC ?v0 ?v1 ?v2)"),
            // Custom searchers
            build_unop_rule("neg", "VecNeg"),
            build_unop_rule("sqrt", "VecSqrt"),
            build_unop_rule("sgn", "VecSgn"),
            build_binop_rule("/", "VecDiv"),
            build_binop_or_zero_rule("+", "VecAdd"),
            build_binop_or_zero_rule("*", "VecMul"),
            build_binop_or_zero_rule("-", "VecMinus"),
            // build_mac_rule(),

            // rw!("intros-join"; "(Vec ?a ?b ?c ?d)" => "(Join (VecTwo ?a ?b) (VecTwo ?c ?d))"),
            rw!("intros-aligned-vec-load2"; "(VecTwo (Load ?a0 ?b0 ?o0) (Load ?a1 ?b1 ?o1))" => "(AlignedConsecVecLoad2 ?a0)" if memory_is_aligned_and_consec2("?b0", "?b1", "?o0", "?o1")),
        ]);
    } else {
        eprintln!("Skipping vector rules")
    }

    if !no_ac {
        rules.extend(vec![
            //  Basic associativity/commutativity/identities
            rw!("commute-add"; "(+ ?a ?b)" => "(+ ?b ?a)"),
            rw!("commute-mul"; "(* ?a ?b)" => "(* ?b ?a)"),
            rw!("assoc-add"; "(+ (+ ?a ?b) ?c)" => "(+ ?a (+ ?b ?c))"),
            rw!("assoc-mul"; "(* (* ?a ?b) ?c)" => "(* ?a (* ?b ?c))"),
        ]);
    }

    // // Context Rules
    // rules.extend(vec![
    //     // rw!("commute-add-context"; "(Vec (+ ?a0 ?b0) (- ?a1 ?b1) (+ ?a2 ?b2) (- ?a3 ?b3))" => "(Shuffle (Vec (+ ?a0 ?b0) (+ ?a2 ?b2) (- ?a1 ?b1) (- ?a3 ?b3)) (DataVec 0 2 1 3))"),
    //     // rw!("commute-add-context"; "(Vec (- ?a0 ?b0) (+ ?a1 ?b1) (- ?a2 ?b2) (+ ?a3 ?b3))" => "(Shuffle (Vec (- ?a0 ?b0) (- ?a2 ?b2) (+ ?a1 ?b1) (+ ?a3 ?b3)) (DataVec 0 2 1 3))"),

    //     rw!("commute-add-context"; "(Vec (+ ?a0 ?b0) (* ?a1 ?b1) (+ ?a2 ?b2) (* ?a3 ?b3))" => "(Shuffle (Vec (+ ?a0 ?b0) (+ ?a2 ?b2) (* ?a1 ?b1) (* ?a3 ?b3)) (DataVec 0 2 1 3))"),
    //     rw!("commute-add-context"; "(Vec (* ?a0 ?b0) (+ ?a1 ?b1) (* ?a2 ?b2) (+ ?a3 ?b3))" => "(Shuffle (Vec (* ?a0 ?b0) (* ?a2 ?b2) (+ ?a1 ?b1) (+ ?a3 ?b3)) (DataVec 0 2 1 3))"),
    // ]);

    // Data Movement Rules
    // shuffle rules
    rules.extend(vec![
        // rw!("vec2-permutation"; "(VecTwo ?a ?b)" => "(VecTwo ?b ?a)"),

        // The below commented out rules are completely wrong and should never occur or be used.
        // rw!("shuffle-op1"; "(Vec (VecAdd ?a ?b) (VecMinus ?c ?d) (VecAdd ?e ?f) (VecMinus ?g ?h))" => "(Shuffle (Vec (VecAdd ?a ?b) (VecAdd ?e ?f) (VecMinus ?c ?d) (VecMinus ?g ?h)) (DataVec 0 2 1 3))"),


        // rw!("shuffle-op-A1M1A2M2-A1A2M1M2"; "(Vec (VecAdd ?a ?b) (VecMul ?c ?d) (VecAdd ?e ?f) (VecMul ?g ?h))" => "(Shuffle (Vec (VecAdd ?a ?b) (VecAdd ?e ?f) (VecMul ?c ?d) (VecMul ?g ?h)) (DataVec 0 2 1 3))"),
        // rw!("shuffle-op-A1M1A2M2-A2A1M1M2"; "(Vec (VecAdd ?a ?b) (VecMul ?c ?d) (VecAdd ?e ?f) (VecMul ?g ?h))" => "(Shuffle (Vec (VecAdd ?e ?f) (VecAdd ?a ?b) (VecMul ?c ?d) (VecMul ?g ?h)) (DataVec 2 0 1 3))"),
        // rw!("shuffle-op-A1M1A2M2-A1A2M2M1"; "(Vec (VecAdd ?a ?b) (VecMul ?c ?d) (VecAdd ?e ?f) (VecMul ?g ?h))" => "(Shuffle (Vec (VecAdd ?a ?b) (VecAdd ?e ?f) (VecMul ?g ?h) (VecMul ?c ?d)) (DataVec 0 2 3 1))"),
        // rw!("shuffle-op-A1M1A2M2-A2A1M2M1"; "(Vec (VecAdd ?a ?b) (VecMul ?c ?d) (VecAdd ?e ?f) (VecMul ?g ?h))" => "(Shuffle (Vec (VecAdd ?e ?f) (VecAdd ?a ?b) (VecMul ?g ?h) (VecMul ?c ?d)) (DataVec 2 0 3 1))"),
        // rw!("shuffle-op4"; "(Vec (VecAdd ?a ?b) (VecMul ?c ?d) (VecAdd ?e ?f) (VecMul ?g ?h))" => "(Shuffle (Vec (VecAdd ?e ?f) (VecAdd ?a ?b) (VecMul ?c ?d) (VecMul ?g ?h)) (DataVec 2 0 1 3))"),
        // rw!("shuffle-op5"; "(Vec (VecMul ?a ?b) (VecAdd ?c ?d) (VecMul ?e ?f) (VecAdd ?g ?h))" => "(Shuffle (Vec (VecMul ?a ?b) (VecMul ?e ?f) (VecAdd ?c ?d) (VecAdd ?g ?h)) (DataVec 0 2 1 3))"),


        // rw!("shuffle-load-vec"; "(Vec (Load ?a0 ?b0 ?o0) (Load ?a1 ?b1 ?o1) (Load ?a2 ?b2 ?o2) (Load ?a3 ?b3 ?o3))" => { PermuteLoad {
        //     a0: "?a0".parse().unwrap(),
        //     a1: "?a1".parse().unwrap(),
        //     a2: "?a2".parse().unwrap(),
        //     a3: "?a3".parse().unwrap(),
        //     b0: "?b0".parse().unwrap(),
        //     b1: "?b1".parse().unwrap(),
        //     b2: "?b2".parse().unwrap(),
        //     b3: "?b3".parse().unwrap(),
        //     o0: "?o0".parse().unwrap(),
        //     o1: "?o1".parse().unwrap(),
        //     o2: "?o2".parse().unwrap(),
        //     o3: "?o3".parse().unwrap(),
        // }}),
    ]);

    // split vec rules

    rules
}

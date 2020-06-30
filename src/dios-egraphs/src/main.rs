use egg::{rewrite as rw, *};

// Overall thoughts: start with spec, not the reference implementation
// Mutation is hard: how do we model vector registers?
//   What if the language produces essentially an entire register file?
//   Tuple of expressions for what to do with vector registers - we want
//     all of the "goal" entities to exist somewhere in the register file
// What do we do about long lists/variadic instructions?
//   Can we have something called "vector run" where we give it a list of
//     mutating instructions to run?
// What do we do about shuffle instructions?
//   Can we model vectors as sets instead of lists?
//   Can we have a magic shuffle encoded, and the SMT/external solver
//     tries to realize that?
// Eventually, do we want to model loads and stores?
// Assuming this gives up a perfect sketch minus exact shuffles, do we no
//   longer have to encode exact function semantics into SMT?


// What are the principals behind creating these rules?

define_language! {
    enum VecLang {
        Num(i32),

        // Id is a key to identify EClasses within an EGraph, represents
        // children nodes
        "+" = Add(Box<[Id]>),
        "*" = Mul(Box<[Id]>),

        // Lists have a variable number of elements
        "List" = List(Box<[Id]>),

        // Vectors have 4 elements
        "Vec4" = Vec4([Id; 4]),

        // Used for partitioning and recombining lists
        "Concat" = Concat([Id; 2]),

        // Vector operations that take 2 vectors of inputs
        "VecAdd" = VecAdd([Id; 2]),
        "VecMul" = VecMul([Id; 2]),

        // MAC takes 3 lists: acc, v1, v2
        "VecMAC" = VecMAC([Id; 3]),

        // language items are parsed in order, and we want symbol to
        // be a fallback, so we put it last.
        // `Symbol` is an egg-provided interned string type
        Symbol(egg::Symbol),
    }
}

type EGraph = egg::EGraph<VecLang, VecLangAnalysis>;

#[derive(Default)]
struct VecLangAnalysis;

#[derive(Debug)]
struct Data {
}

impl Analysis<VecLang> for VecLangAnalysis {
    type Data = Data;
    fn merge(&self, _to: &mut Data, _from: Data) -> bool {
        false
    }

    fn make(_egraph: &EGraph, _enode: &VecLang) -> Data {
        Data { }
    }
}

struct ListApplier(&'static str);
impl Applier<VecLang, VecLangAnalysis> for ListApplier {
    fn apply_one(&self, _: &mut EGraph, _: Id, _: &Subst) -> Vec<Id> {
        panic!()
    }
}

// // This returns a function that implements Condition
// fn is_not_zero(var: &'static str) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
//     let var = var.parse().unwrap();
//     let zero = VecLang::Num(0);
//     move |egraph, _, subst| !egraph[subst[var]].nodes.contains(&zero)
// }

struct VecCostFn;
impl CostFunction<VecLang> for VecCostFn {
    type Cost = f64;
    // you're passed in an enode whose children are costs instead of eclass ids
    fn cost<C>(&mut self, enode: &VecLang, mut costs: C) -> Self::Cost
    where
        C: FnMut(Id) -> Self::Cost,
    {
        let op_cost = match enode {
            // You get literals for extremely cheap
            VecLang::Num(..) => 0.01,
            VecLang::Symbol(..) => 0.01,

            // And list/vector structures for quite cheap
            VecLang::List(..) => 0.1,
            VecLang::Vec4(..) => 0.1,
            VecLang::Concat(..) => 0.1,

            // But scalar and vector ops cost something
            VecLang::Add(..) => 1.,
            VecLang::Mul(..) => 1.,

            VecLang::VecAdd(..) => 1.,
            VecLang::VecMul(..) => 1.,
            VecLang::VecMAC(..) => 1.,
        };
        enode.fold(op_cost, |sum, id| sum + costs(id))
    }
}

fn main() {
    let mut rules: Vec<Rewrite<VecLang, ()>> = vec![
        rw!("commute-add"; "(+ ?a ?b)" => "(+ ?b ?a)"),
        rw!("commute-mul"; "(* ?a ?b)" => "(* ?b ?a)"),
        rw!("assoc-add-1"; "(+ ?a ?b ?c)" => "(+ ?a (+ ?b ?c))"),
        rw!("assoc-add-2"; "(+ ?a ?b ?c)" => "(+ (+ ?a ?b) ?c)"),
        rw!("assoc-mul-1"; "(* ?a ?b ?c)" => "(* ?a (* ?b ?c))"),
        rw!("assoc-mul-2"; "(* ?a ?b ?c)" => "(* (* ?a ?b) ?c))"),
        // rw!("add-0"; "(+ ?a 0)" => "?a"),
        rw!("mul-0"; "(* ?a 0)" => "0"),
        rw!("mul-1"; "(* ?a 1)" => "?a"),

        // Allow hallucination of 0's to allow pattern matching larger vectors
        rw!("zero-1"; "?a" => "(+ ?a 0)"),
        rw!("zero-2"; "0" => "(* 0 0)"),

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

    // Simple vector add
    {
        let start = "(List (+ a b) (+ c d))".parse().unwrap();
        let runner = Runner::default().with_expr(&start).run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner.iterations.len(),
            runner.stop_reason
        );

        let (egraph, root) = (runner.egraph, runner.roots[0]);

        let mut extractor = Extractor::new(&egraph, VecCostFn);
        let (best_cost, best) = extractor.find_best(root);
        println!("Best cost {}", best_cost);
        assert_eq!(best, "(VecAdd (Vec4 a c 0 0) (Vec4 b d 0 0))".parse().unwrap());
    }

    // Nest vector MAC and vector mul with size = 2
    {
        let start = "(List
                       (+ (* a b) (+ (* c d) (* e f)))
                       (+ (* aa bb) (+ (* cc dd) (* ee ff))))"
            .parse()
            .unwrap();
        let runner = Runner::default().with_expr(&start).run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner.iterations.len(),
            runner.stop_reason
        );

        let (egraph, root) = (runner.egraph, runner.roots[0]);

        let mut extractor = Extractor::new(&egraph, VecCostFn);
        let (best_cost, best) = extractor.find_best(root);
        println!(
            "original:\n{}\nbest:\n{}\nbest cost {}",
            start.pretty(40),
            best.pretty(40),
            best_cost,
        );
        assert_eq!(
            best,
            "(VecMAC
              (VecMAC
                (VecMul (Vec4 e ee 0 0) (Vec4 f ff 0 0))
                (Vec4 c cc 0 0)
                (Vec4 d dd 0 0))
              (Vec4 a aa 0 0)
              (Vec4 b bb 0 0))"
                .parse()
                .unwrap()
        );
    }

    // Nest vector MAC and vector mul with size = 2, variadic add
    {
        let start = "(List
                       (+ (* a b) (* c d) (* e f))
                       (+ (* aa bb) (* cc dd) (* ee ff)))"
            .parse()
            .unwrap();
        let runner = Runner::default().with_expr(&start).run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner.iterations.len(),
            runner.stop_reason
        );

        let (egraph, root) = (runner.egraph, runner.roots[0]);

        let mut extractor = Extractor::new(&egraph, VecCostFn);
        let (best_cost, best) = extractor.find_best(root);
        println!(
            "original:\n{}\nbest:\n{}\nbest cost {}",
            start.pretty(40),
            best.pretty(40),
            best_cost,
        );
        assert_eq!(
            best,
            "(VecMAC
                  (VecMAC
                    (VecMul (Vec4 e ee 0 0) (Vec4 f ff 0 0))
                    (Vec4 c cc 0 0)
                    (Vec4 d dd 0 0))
                  (Vec4 a aa 0 0)
                  (Vec4 b bb 0 0))"
                .parse()
                .unwrap()
        );
    }

    // 2x2 by 2x2 matrix multiply
    // (list
    //  (box (bvadd (bvmul v$0 v$4) (bvmul v$1 v$6)))
    //  (box (bvadd (bvmul v$0 v$5) (bvmul v$1 v$7)))
    //  (box (bvadd (bvmul v$2 v$4) (bvmul v$3 v$6)))
    //  (box (bvadd (bvmul v$2 v$5) (bvmul v$3 v$7))))
    {
        let start = "(List
                       (+ (* v0 v4) (* v1 v6))
                       (+ (* v0 v5) (* v1 v7))
                       (+ (* v2 v4) (* v3 v6))
                       (+ (* v2 v5) (* v3 v7)))"
            .parse()
            .unwrap();
        let runner = Runner::default().with_expr(&start).run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner.iterations.len(),
            runner.stop_reason
        );

        let (egraph, root) = (runner.egraph, runner.roots[0]);

        let mut extractor = Extractor::new(&egraph, VecCostFn);
        let (best_cost, best) = extractor.find_best(root);
        println!(
            "original:\n{}\nbest:\n{}\nbest cost {}",
            start.pretty(40),
            best.pretty(40),
            best_cost,
        );
        assert_eq!(
            best,
            "(VecMAC
              (VecMul
                (Vec4 v0 v0 v4 v5)
                (Vec4 v4 v5 v2 v2))
              (Vec4 v1 v1 v6 v7)
              (Vec4 v6 v7 v3 v3))"
                .parse()
                .unwrap()
        );
    }

    // (list
    //  (box (bvadd (bvmul v$0 v$6) (bvmul v$1 v$9) (bvmul v$2 v$12)))
    //  (box (bvadd (bvmul v$0 v$7) (bvmul v$1 v$10) (bvmul v$2 v$13)))
    //  (box (bvadd (bvmul v$0 v$8) (bvmul v$1 v$11) (bvmul v$2 v$14)))
    //  (box (bvadd (bvmul v$3 v$6) (bvmul v$4 v$9) (bvmul v$5 v$12)))
    //  (box (bvadd (bvmul v$3 v$7) (bvmul v$4 v$10) (bvmul v$5 v$13)))
    //  (box (bvadd (bvmul v$3 v$8) (bvmul v$4 v$11) (bvmul v$5 v$14))))
    {
        let start = "(List
                        (+ (* v0 v6) (* v1 v9)  (* v2 v12))
                        (+ (* v0 v7) (* v1 v10) (* v2 v13))
                        (+ (* v0 v8) (* v1 v11) (* v2 v14))
                        (+ (* v3 v6) (* v4 v9)  (* v5 v12))
                        (+ (* v3 v7) (* v4 v10) (* v5 v13))
                        (+ (* v3 v8) (* v4 v11) (* v5 v14)))"
            .parse()
            .unwrap();
        let runner = Runner::default()
            .with_expr(&start)
            .with_node_limit(100_000)
            .with_time_limit(std::time::Duration::from_secs(20))
            .with_iter_limit(60)
            .run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner.iterations.len(),
            runner.stop_reason
        );

        let (egraph, root) = (runner.egraph, runner.roots[0]);

        let mut extractor = Extractor::new(&egraph, VecCostFn);
        let (best_cost, best) = extractor.find_best(root);
        println!(
            "original:\n{}\nbest:\n{}\nbest cost {}",
            start.pretty(40),
            best.pretty(40),
            best_cost,
        );
        assert_eq!(
            best,
            "(Concat
              (VecMAC
                (VecMAC
                  (VecMul
                    (Vec4 v2 v2 v2 v12)
                    (Vec4 v12 v13 v14 v5))
                  (Vec4 v1 v1 v1 v9)
                  (Vec4 v9 v10 v11 v4))
                (Vec4 v0 v0 v0 v6)
                (Vec4 v6 v7 v8 v3))
              (VecMAC
                (VecMAC
                  (VecMul
                    (Vec4 v13 v14 0 0)
                    (Vec4 v5 v5 0 0))
                  (Vec4 v10 v11 0 0)
                  (Vec4 v4 v4 0 0))
                (Vec4 v7 v8 0 0)
                (Vec4 v3 v3 0 0)))"
                .parse()
                .unwrap()
        );
    }
    {
        let start = "(List
                         (* v0 v4)
                         (+ (* v0 v5) (* v1 v4))
                         (* v1 v5)
                         (+ (* v0 v6) (* v2 v4))
                         (+ (* v0 v7) (* v1 v6) (* v2 v5) (* v3 v4))
                         (+ (* v1 v7) (* v3 v5))
                         (* v2 v6)
                         (+ (* v2 v7) (* v3 v6))
                         (* v3 v7))"
            .parse()
            .unwrap();
        let runner = Runner::default().with_expr(&start).run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner.iterations.len(),
            runner.stop_reason
        );

        let (egraph, root) = (runner.egraph, runner.roots[0]);

        let mut extractor = Extractor::new(&egraph, VecCostFn);
        let (best_cost, best) = extractor.find_best(root);
        println!(
            "original:\n{}\nbest:\n{}\nbest cost {}",
            start.pretty(40),
            best.pretty(40),
            best_cost,
        );
    }


        // let start = "(Vec4
        //                 (+ (* v0 v7) (* v1 v6) (* v2 v5) (* v3 v4))
        //                 (+ (* v1 v7) (* v3 v5))
        //                 (* v2 v6)
        //                 (+ (* v2 v7) (* v3 v6)))"

    // THIS ONE WORKS
        // let start = "(Vec4
        //                 (+ (* v0 v7) (+ (* v1 v6) (+ (* v2 v5) (* v3 v4))))
        //                 (+ (* v1 v7) (+ (* v3 v5) (+ (* 0 0) (* 0 0))))
        //                 (+ (* v2 v6) (+ (* 0 0) (+ (* 0 0) (* 0 0))))
        //                 (+ (* v2 v7) (+ (* v3 v6) (+ (* 0 0) (* 0 0)))))"

    // This one finds cost = 4
    // Pattern search example
    {
        let start = "(Vec4
                        (+ (* v0 v7) (* v1 v6) (* v2 v5) (* v3 v4))
                        (+ (* v1 v7) (* v3 v5))
                        (* v2 v6)
                        (+ (* v2 v7) (* v3 v6)))"
            .parse()
            .unwrap();
        let runner = Runner::default()
            .with_expr(&start)
            .with_node_limit(100_000)
            .with_time_limit(std::time::Duration::from_secs(60))
            .with_iter_limit(60)
            .run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner.iterations.len(),
            runner.stop_reason
        );

        let (egraph, root) = (runner.egraph, runner.roots[0]);

        let mut extractor = Extractor::new(&egraph, VecCostFn);
        let (best_cost, best) = extractor.find_best(root);
        println!(
            "original:\n{}\nbest:\n{}\nbest cost {}",
            start.pretty(40),
            best.pretty(40),
            best_cost,
        );
    }

    // Compare all 3 expressions
    {
        let start_with_zero: RecExpr<VecLang>  = "(Vec4
                        (+ (* v0 v7) (+ (* v1 v6) (+ (* v2 v5) (* v3 v4))))
                        (+ (* v1 v7) (+ (* v3 v5) 0))
                        (+ (* v2 v6) 0)
                        (+ (* v2 v7) (+ (* v3 v6) 0)))"
            .parse()
            .unwrap();
        let start_simplified: RecExpr<VecLang> = "(Vec4
                        (+ (* v0 v7) (+ (* v1 v6) (+ (* v2 v5) (* v3 v4))))
                        (+ (* v1 v7) (+ (* v3 v5) 0))
                        (* v2 v6)
                        (+ (* v2 v7) (+ (* v3 v6) 0)))"
            .parse()
            .unwrap();
        let goal: RecExpr<VecLang> = "(VecMAC
                      (VecMAC
                        (VecMAC
                          (Vec4 (* v3 v4) 0 0 0)
                          (Vec4 v2 0 0 v6)
                          (Vec4 v5 0 0 v3))
                        (Vec4 v1 v5 0 0)
                        (Vec4 v6 v3 0 0))
                      (Vec4 v0 v7 v6 v7)
                      (Vec4 v7 v1 v2 v2))"
            .parse()
            .unwrap();

        let runner1 = Runner::default()
            .with_expr(&start_with_zero)
            .with_node_limit(100_000)
            .with_time_limit(std::time::Duration::from_secs(20))
            .with_iter_limit(60)
            .run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner1.iterations.len(),
            runner1.stop_reason
        );

        let (mut egraph1, _) = (runner1.egraph, runner1.roots[0]);

        assert_eq!(egraph1.add_expr(&start_with_zero), egraph1.add_expr(&start_simplified));
        assert_eq!(egraph1.add_expr(&start_with_zero), egraph1.add_expr(&goal));
        assert_eq!(egraph1.add_expr(&start_simplified), egraph1.add_expr(&goal));

        let runner2 = Runner::default()
            .with_expr(&start_simplified)
            .with_node_limit(100_000)
            .with_time_limit(std::time::Duration::from_secs(20))
            .with_iter_limit(60)
            .run(&rules);
        println!(
            "Stopped after {} iterations, reason: {:?}",
            runner2.iterations.len(),
            runner2.stop_reason
        );

        let (mut egraph2, _) = (runner2.egraph, runner2.roots[0]);

        assert_eq!(egraph2.add_expr(&start_with_zero), egraph2.add_expr(&start_simplified));
        assert_eq!(egraph2.add_expr(&start_with_zero), egraph2.add_expr(&goal));
        assert_eq!(egraph2.add_expr(&start_simplified), egraph2.add_expr(&goal));
    }

    }

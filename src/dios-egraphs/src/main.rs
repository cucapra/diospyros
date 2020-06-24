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

define_language! {
    enum VecLang {
        Num(i32),
        // What exactly does Id mean?
        "+" = Add([Id; 2]),
        "*" = Mul([Id; 2]),
        // For now, lists have 2 elements
        "List" = List([Id; 2]),
        "VecAdd" = VecAdd([Id; 2]),
        "VecMul" = VecMul([Id; 2]),
        "VecMAC" = VecMAC([Id; 3]),
        // language items are parsed in order, and we want symbol to
        // be a fallback, so we put it last.
        // `Symbol` is an egg-provided interned string type
        Symbol(egg::Symbol),
    }
}

struct VecCostFn;
impl CostFunction<VecLang> for VecCostFn {
    type Cost = usize;
    // you're passed in an enode whose children are costs instead of eclass ids
    fn cost<C>(&mut self, enode: &VecLang, mut costs: C) -> Self::Cost
    where
        C: FnMut(Id) -> Self::Cost,
    {
        // You get Lists for free, all other ops cost 1 for now
        let op_cost = match enode {
            VecLang::List(..) => 0,

            VecLang::Add(..) => 1,
            VecLang::Mul(..) => 1,

            VecLang::VecAdd(..) => 1,
            VecLang::VecMul(..) => 1,
            VecLang::VecMAC(..) => 1,
            _ => 0,
        };
        enode.fold(op_cost, |sum, id| sum + costs(id))
    }
}

fn main() {
    let rules: &[Rewrite<VecLang, ()>] = &[
        rw!("commute-add"; "(+ ?a ?b)" => "(+ ?b ?a)"),
        rw!("commute-mul"; "(* ?a ?b)" => "(* ?b ?a)"),
        rw!("add-0"; "(+ ?a 0)" => "?a"),
        rw!("mul-0"; "(* ?a 0)" => "0"),
        rw!("mul-1"; "(* ?a 1)" => "?a"),
        rw!("vec-add"; "(List (+ ?a ?b) (+ ?c ?d))"
            => "(VecAdd (List ?a ?c) (List ?b ?d))"),
        rw!("vec-mul"; "(List (* ?a ?b) (* ?c ?d))"
            => "(VecMul (List ?a ?c) (List ?b ?d))"),
        rw!("vec-mac"; "(List (+ ?a (* ?b ?c)) (+ ?d (* ?e ?f)))"
            => "(VecMAC (List ?a ?d) (List ?b ?e) (List ?c ?f))"),
    ];

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
        assert_eq!(best, "(VecAdd (List a c) (List b d))".parse().unwrap());
    }

    // Nest vector MAC and vector mul
    {
        let start = "(List (+ (* a b) (+ (* c d) (* e f))) (+ (* aa bb) (+ (* cc dd) (* ee ff))))"
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
            start,
            best.pretty(40),
            best_cost,
        );
        assert_eq!(
            best,
            "(VecMAC
                            (VecMAC
                              (VecMul (List c cc) (List d dd))
                              (List e ee)
                              (List f ff))
                            (List a aa)
                            (List b bb))"
                .parse()
                .unwrap()
        );
    }
}

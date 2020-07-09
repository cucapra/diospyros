use egg::{*};

use crate::{
    veclang::{VecLang},
    rules::{*},
    cost::{*},
};

pub mod veclang;
pub mod rules;
pub mod cost;

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

// // This returns a function that implements Condition
// fn is_not_zero(var: &'static str) -> impl Fn(&mut EGraph, Id, &Subst) -> bool {
//     let var = var.parse().unwrap();
//     let zero = VecLang::Num(0);
//     move |egraph, _, subst| !egraph[subst[var]].nodes.contains(&zero)
// }

fn main() {
    let rules = rules();

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
    {
        let start = "(Concat
          (Vec4
            (* v0 v9)
            (+ (* v0 v10) (* v1 v9))
            (+ (* v0 v11) (* v1 v10) (* v2 v9))
            (+ (* v1 v11) (* v2 v10)))
          (Concat
            (Vec4
              (* v2 v11)
              (+ (* v0 v12) (* v3 v9))
              (+ (* v0 v13) (* v1 v12) (* v3 v10) (* v4 v9))
              (+ (* v0 v14)
                 (* v1 v13)
                 (* v2 v12)
                 (* v3 v11)
                 (* v4 v10)
                 (* v5 v9)))
            (Concat
              (Vec4
                (+ (* v1 v14)
                   (* v2 v13)
                   (* v4 v11)
                   (* v5 v10))
                (+ (* v2 v14) (* v5 v11))
                (+ (* v0 v15) (* v3 v12) (* v6 v9))
                (+ (* v0 v16)
                   (* v1 v15)
                   (* v3 v13)
                   (* v4 v12)
                   (* v6 v10)
                   (* v7 v9)))
              (Concat
                (Vec4
                  (+ (* v0 v17)
                     (* v1 v16)
                     (* v2 v15)
                     (* v3 v14)
                     (* v4 v13)
                     (* v5 v12)
                     (* v6 v11)
                     (* v7 v10)
                     (* v8 v9))
                  (+ (* v1 v17)
                     (* v2 v16)
                     (* v4 v14)
                     (* v5 v13)
                     (* v7 v11)
                     (* v8 v10))
                  (+ (* v2 v17) (* v5 v14) (* v8 v11))
                  (+ (* v3 v15) (* v6 v12)))
                (Concat
                  (Vec4
                    (+ (* v3 v16) (* v4 v15) (* v6 v13) (* v7 v12))
                    (+ (* v3 v17)
                       (* v4 v16)
                       (* v5 v15)
                       (* v6 v14)
                       (* v7 v13)
                       (* v8 v12))
                    (+ (* v4 v17) (* v5 v16) (* v7 v14) (* v8 v13))
                    (+ (* v5 v17) (* v8 v14)))
                  (Concat
                    (Vec4
                      (* v6 v15)
                      (+ (* v6 v16) (* v7 v15))
                      (+ (* v6 v17) (* v7 v16) (* v8 v15))
                      (+ (* v7 v17) (* v8 v16)))
                    (List
                      (* v8 v17))))))))"
            .parse()
            .unwrap();
        let runner = Runner::default()
            .with_expr(&start)
            .with_node_limit(900_000)
            .with_time_limit(std::time::Duration::from_secs(120))
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
}

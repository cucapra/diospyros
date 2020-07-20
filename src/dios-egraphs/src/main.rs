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

fn main() {
}

#[cfg(test)]
mod tests {

  use egg::{*};
  use assert_approx_eq::assert_approx_eq;
  use super::{
      veclang::{VecLang},
      rules::{*},
      cost::{*},
  };

  fn run_egpraph_with_start(str : &str, exp_best : &str, exp_best_cost : f64) {
    let rules = rules();
    let start = str.parse().unwrap();
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

    let (eg, root) = (runner.egraph, runner.roots[0]);

    let mut extractor = Extractor::new(&eg, VecCostFn { egraph: &eg });
    let (best_cost, best) = extractor.find_best(root);

    println!(
      "original:\n{}\nbest:\n{}\nbest cost {}",
      start.pretty(40),
      best.pretty(40),
      best_cost,
    );
    assert_eq!(best, exp_best.parse().unwrap());
    assert_approx_eq!(best_cost, exp_best_cost, 0.000001);
  }


  #[test]
  fn simple_vector_add() {
    let start = "(List (+ a b) (+ c d))";
    let exp_best = "(VecAdd (Vec4 a c 0 0) (Vec4 b d 0 0))";
    let exp_best_cost = 1.208;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_mac_pairwise_add() {
    let start = "(List
                   (+ (* a b) (+ (* c d) (* e f)))
                   (+ (* aa bb) (+ (* cc dd) (* ee ff))))";
    let exp_best = "(VecMAC
                      (VecMAC
                        (VecMul (Vec4 e ee 0 0) (Vec4 f ff 0 0))
                        (Vec4 c cc 0 0)
                        (Vec4 d dd 0 0))
                      (Vec4 a aa 0 0)
                      (Vec4 b bb 0 0))";
    let exp_best_cost = 3.624;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_mac_variadic_add() {
    let start = "(List
                   (+ (* a b) (* c d) (* e f))
                   (+ (* aa bb) (* cc dd) (* ee ff)))";
    let exp_best = "(VecMAC
                      (VecMAC
                        (VecMul (Vec4 e ee 0 0) (Vec4 f ff 0 0))
                        (Vec4 c cc 0 0)
                        (Vec4 d dd 0 0))
                      (Vec4 a aa 0 0)
                      (Vec4 b bb 0 0))";
    let exp_best_cost = 3.624;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_matrix_multiply_2x2_2x2() {
    let start = "(List
                   (+ (* v0 v4) (* v1 v6))
                   (+ (* v0 v5) (* v1 v7))
                   (+ (* v2 v4) (* v3 v6))
                   (+ (* v2 v5) (* v3 v7)))";
    let exp_best = "(VecMAC
                      (VecMul
                        (Vec4 v0 v0 v4 v5)
                        (Vec4 v4 v5 v2 v2))
                      (Vec4 v1 v1 v6 v7)
                      (Vec4 v6 v7 v3 v3))";
    let exp_best_cost = 2.416;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  // Currently fails, need to prioritize same memories in vector
  #[test]
  fn vector_matrix_multiply_2x2_2x2_explicit_get() {
    let start = "(List
                    (+ (* (Get a 0) (Get b 0)) (* (Get a 1) (Get b 2)))
                    (+ (* (Get a 0) (Get b 1)) (* (Get a 1) (Get b 3)))
                    (+ (* (Get a 2) (Get b 0)) (* (Get a 3) (Get b 2)))
                    (+ (* (Get a 2) (Get b 1)) (* (Get a 3) (Get b 3))))";
    let exp_best = "(VecMAC
                      (VecMul
                        (LitVec4 (Get a 0) (Get a 0) (Get a 2) (Get a 2))
                        (LitVec4 (Get b 0) (Get b 1) (Get b 0) (Get b 1)))
                      (LitVec4 (Get a 1) (Get a 1) (Get a 3) (Get a 3))
                      (LitVec4 (Get b 2) (Get b 3) (Get b 2) (Get b 3)))";
    let exp_best_cost = 2.052;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_matrix_multiply_2x3_3x3() {
    let start = "(List
                  (+ (* v0 v6) (* v1 v9)  (* v2 v12))
                  (+ (* v0 v7) (* v1 v10) (* v2 v13))
                  (+ (* v0 v8) (* v1 v11) (* v2 v14))
                  (+ (* v3 v6) (* v4 v9)  (* v5 v12))
                  (+ (* v3 v7) (* v4 v10) (* v5 v13))
                  (+ (* v3 v8) (* v4 v11) (* v5 v14)))";
    let exp_best = "(Concat
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
                        (Vec4 v3 v3 0 0)))";
    let exp_best_cost = 7.348;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_matrix_multiply_2x3_3x3_explicit_get() {
    let start = "(List
                  (+
                    (* (Get A 0) (Get B 0))
                    (* (Get A 1) (Get B 3))
                    (* (Get A 2) (Get B 6)))
                  (+
                    (* (Get A 0) (Get B 1))
                    (* (Get A 1) (Get B 4))
                    (* (Get A 2) (Get B 7)))
                  (+
                    (* (Get A 0) (Get B 2))
                    (* (Get A 1) (Get B 5))
                    (* (Get A 2) (Get B 8)))
                  (+
                    (* (Get A 3) (Get B 0))
                    (* (Get A 4) (Get B 3))
                    (* (Get A 5) (Get B 6)))
                  (+
                    (* (Get A 3) (Get B 1))
                    (* (Get A 4) (Get B 4))
                    (* (Get A 5) (Get B 7)))
                  (+
                    (* (Get A 3) (Get B 2))
                    (* (Get A 4) (Get B 5))
                    (* (Get A 5) (Get B 8))))";
    let exp_best = "(Concat
                      (VecMAC
                        (VecMAC
                          (VecMul
                            (LitVec4
                              (Get A 2)
                              (Get A 2)
                              (Get A 2)
                              (Get A 5))
                            (LitVec4
                              (Get B 6)
                              (Get B 7)
                              (Get B 8)
                              (Get B 6)))
                          (LitVec4
                            (Get A 1)
                            (Get A 1)
                            (Get A 1)
                            (Get A 4))
                          (LitVec4
                            (Get B 3)
                            (Get B 4)
                            (Get B 5)
                            (Get B 3)))
                        (LitVec4
                          (Get A 0)
                          (Get A 0)
                          (Get A 0)
                          (Get A 3))
                        (LitVec4
                          (Get B 0)
                          (Get B 1)
                          (Get B 2)
                          (Get B 0)))
                      (VecMAC
                        (VecMAC
                          (VecMul
                            (Vec4 (Get B 7) (Get B 8) 0 0)
                            (Vec4 (Get A 5) (Get A 5) 0 0))
                          (Vec4 (Get B 4) (Get B 5) 0 0)
                          (Vec4 (Get A 4) (Get A 4) 0 0))
                        (Vec4 (Get B 1) (Get B 2) 0 0)
                        (Vec4 (Get A 3) (Get A 3) 0 0)))";
    let exp_best_cost = 6.826;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_2d_conv_2x2_2x2() {
    let start = "(List
                   (* v0 v4)
                   (+ (* v0 v5) (* v1 v4))
                   (* v1 v5)
                   (+ (* v0 v6) (* v2 v4))
                   (+ (* v0 v7) (* v1 v6) (* v2 v5) (* v3 v4))
                   (+ (* v1 v7) (* v3 v5))
                   (* v2 v6)
                   (+ (* v2 v7) (* v3 v6))
                   (* v3 v7))";
    let exp_best = "(Concat
                      (VecMAC
                        (VecMul
                          (Vec4 v0 v0 v5 v0)
                          (Vec4 v4 v5 v1 v6))
                        (Vec4 0 v4 0 v4)
                        (Vec4 0 v1 0 v2))
                      (Concat
                        (VecMAC
                          (VecMAC
                            (VecMAC
                              (VecMul (Vec4 v3 0 0 0) (Vec4 v4 0 0 0))
                              (Vec4 v5 0 0 0)
                              (Vec4 v2 0 0 0))
                            (Vec4 v1 v5 0 v6)
                            (Vec4 v6 v3 0 v3))
                          (Vec4 v0 v1 v6 v2)
                          (Vec4 v7 v7 v2 v7))
                        (VecMul (Vec4 v7 0 0 0) (Vec4 v3 0 0 0))))";
    let exp_best_cost = 8.656;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_2d_conv_3x3_3x3() {
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
                      (* v8 v17))))))))";
    let exp_best = "(Concat
                      (VecMAC
                        (VecMAC
                          (VecMul
                            (Vec4 0 v9 v9 v10)
                            (Vec4 0 v1 v2 v2))
                          (Vec4 0 0 v10 0)
                          (Vec4 0 0 v1 0))
                        (Vec4 v0 v0 v0 v1)
                        (Vec4 v9 v10 v11 v11))
                      (Concat
                        (VecAdd
                          (VecMAC
                            (VecMAC
                              (VecMul
                                (Vec4 0 v9 v9 0)
                                (Vec4 0 v3 v4 0))
                              (Vec4 0 0 v10 0)
                              (Vec4 0 0 v3 0))
                            (Vec4 v11 v0 v1 0)
                            (Vec4 v2 v12 v12 0))
                          (Vec4
                            0
                            0
                            (* v0 v13)
                            (+
                              (* v0 v14)
                              (* v1 v13)
                              (* v2 v12)
                              (* v11 v3)
                              (* v10 v4)
                              (* v9 v5))))
                        (Concat
                          (VecAdd
                            (Vec4
                              (* v1 v14)
                              0
                              0
                              (+
                                (* v0 v16)
                                (* v1 v15)
                                (* v3 v13)
                                (* v12 v4)
                                (* v10 v6)
                                (* v9 v7)))
                            (VecMAC
                              (VecMAC
                                (VecMul
                                  (Vec4 v10 v11 v12 0)
                                  (Vec4 v5 v5 v3 0))
                                (Vec4 v11 0 v9 0)
                                (Vec4 v4 0 v6 0))
                              (Vec4 v2 v2 v0 0)
                              (Vec4 v13 v14 v15 0)))
                          (Concat
                            (VecMAC
                              (VecMAC
                                (Vec4
                                  (+
                                    (* v0 v17)
                                    (* v1 v16)
                                    (* v2 v15)
                                    (* v3 v14)
                                    (* v13 v4)
                                    (* v12 v5)
                                    (* v11 v6)
                                    (* v10 v7)
                                    (* v9 v8))
                                  (+
                                    (* v1 v17)
                                    (* v2 v16)
                                    (* v4 v14)
                                    (* v13 v5)
                                    (* v11 v7)
                                    (* v10 v8))
                                  (* v2 v17)
                                  0)
                                (Vec4 0 0 v14 v3)
                                (Vec4 0 0 v5 v15))
                              (Vec4 0 0 v11 v12)
                              (Vec4 0 0 v8 v6))
                            (Concat
                              (VecAdd
                                (VecMAC
                                  (Vec4
                                    0
                                    (+
                                      (* v3 v17)
                                      (* v4 v16)
                                      (* v5 v15)
                                      (* v14 v6)
                                      (* v13 v7)
                                      (* v12 v8))
                                    0
                                    0)
                                  (Vec4 v3 0 v4 v5)
                                  (Vec4 v16 0 v17 v17))
                                (VecMAC
                                  (VecMAC
                                    (VecMul
                                      (Vec4 v12 0 v13 0)
                                      (Vec4 v7 0 v8 0))
                                    (Vec4 v13 0 v14 0)
                                    (Vec4 v6 0 v7 0))
                                  (Vec4 v4 0 v5 v14)
                                  (Vec4 v15 0 v16 v8)))
                              (Concat
                                (VecMAC
                                  (VecMAC
                                    (VecMul
                                      (Vec4 0 v15 v15 v16)
                                      (Vec4 0 v7 v8 v8))
                                    (Vec4 0 0 v16 0)
                                    (Vec4 0 0 v7 0))
                                  (Vec4 v15 v6 v6 v7)
                                  (Vec4 v6 v16 v17 v17))
                                (List (* v17 v8))))))))";
    let exp_best_cost = 467.526;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn test_equiv_expressions() {
    let rules = rules();
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

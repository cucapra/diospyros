pub mod veclang;
pub mod rules;
pub mod cost;
pub mod searchutils;
pub mod macsearcher;
pub mod binopsearcher;
pub mod config;

extern crate clap;
use clap::{Arg, App};

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

  let matches = App::new("Diospyros Rewriter")
                    .arg(Arg::with_name("INPUT")
                      .help("Sets the input file")
                      .required(true)
                      .index(1))
                    .arg(Arg::with_name("no-ac")
                      .long("no-ac")
                      .help("Disable associativity and commutativity rules"))
                    .get_matches();



  use std::{env, fs};

  // Get a path string to parse a program.
  let path = matches.value_of("INPUT").unwrap();
  let timeout = env::var("TIMEOUT")
      .ok()
      .and_then(|t| t.parse::<u64>().ok())
      .unwrap_or(180);

  let prog_str = fs::read_to_string(path)
      .expect("Failed to read the input file.");

  let prog = prog_str.parse().unwrap();
  eprintln!("Running egg with timeout {:?}s", timeout);
  let (cost, best) = rules::run(&prog, timeout, matches.is_present("no-ac"));

  println!("{}", best.pretty(40));
  eprintln!("\nCost: {}", cost);
}


// TODO: update the other tests to run without long partitioning rules
#[cfg(test)]
mod tests {

  use egg::{*};
  use assert_approx_eq::assert_approx_eq;
  use super::{
      veclang::{VecLang},
      rules::{*},
  };

  fn run_egpraph_with_start(prog : &str, exp_best : &str, exp_best_cost : f64) {

    let start = prog.parse().unwrap();
    let (best_cost, best) = run(&start, 60, false);

    println!(
      "original:\n{}\nbest:\n{}\nbest cost {}",
      start.pretty(40),
      best.pretty(40),
      best_cost,
    );
    // assert_eq!(best, exp_best.parse().unwrap());
    // Right now as we change searchers, best is not super stable. Just log.
    if best != exp_best.parse().unwrap() {
      println!("Expected best not equal:{}",
        exp_best.parse::<RecExpr<VecLang>>().unwrap().pretty(40));
    }
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
  fn vector_pairwise_mac() {
    let start = "(Vec4
                   (+ (* a b) (+ (* c d) (* e f)))
                   (+ (* aa bb) (+ (* cc dd) (* ee ff)))
                   0
                   0)";
    let exp_best = "(VecMAC
                      (VecMAC
                        (VecMul (Vec4 c aa 0 0) (Vec4 d bb 0 0))
                        (Vec4 e ee 0 0)
                        (Vec4 f ff 0 0))
                      (Vec4 a cc 0 0)
                      (Vec4 b dd 0 0))";
    let exp_best_cost = 3.624;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_variadic_add_mac() {
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
  fn vector_mac() {
    let start = "(Vec4 (+ ?a0 (* ?b0 ?c0))
                       (+ ?a1 (* ?b1 ?c1))
                       (+ ?a2 (* ?b2 ?c2))
                       (+ ?a3 (* ?b3 ?c3)))";
    let exp_best = "(VecMAC (Vec4 ?a0 ?a1 ?a2 ?a3)
                            (Vec4 ?b0 ?b1 ?b2 ?b3)
                            (Vec4 ?c0 ?c1 ?c2 ?c3))";
    let exp_best_cost = 1.312;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  #[test]
  fn vector_mac_just_mul_or_zero() {
    let start = "(Vec4 (+ ?a0 (* ?b0 ?c0))
                       (* ?b1 ?c1)
                       0
                       (+ ?a3 (* ?b3 ?c3)))";
    let exp_best = "(VecMAC (Vec4 ?a0 0 0 ?a3)
                            (Vec4 ?b0 ?b1 0 ?b3)
                            (Vec4 ?c0 ?c1 0 ?c3))";
    let exp_best_cost = 1.312;
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
                        (Vec4 v1 v1 v6 v7)
                        (Vec4 v6 v7 v3 v3))
                      (Vec4 v4 v5 v2 v2)
                      (Vec4 v0 v0 v4 v5))";
    let exp_best_cost = 2.416;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }

  // Currently fails, need to prioritize same memories in vector
  #[test]
  fn vector_matrix_multiply_2x2_2x2_explicit_get() {
    // TODO: with explicit searcher this can't find solution with 4 LitVec4s
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
                            (LitVec4 (Get B 7) (Get B 8) 0 0)
                            (LitVec4 (Get A 5) (Get A 5) 0 0))
                          (LitVec4 (Get B 4) (Get B 5) 0 0)
                          (LitVec4 (Get A 4) (Get A 4) 0 0))
                        (LitVec4 (Get B 1) (Get B 2) 0 0)
                        (LitVec4 (Get A 3) (Get A 3) 0 0)))";
    let exp_best_cost = 6.232;
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
                            (Vec4 0 0 v10 0)
                            (Vec4 0 0 v1 0))
                          (Vec4 0 v0 v9 v1)
                          (Vec4 0 v10 v2 v11))
                        (Vec4 v0 v9 v0 v10)
                        (Vec4 v9 v1 v11 v2))
                      (Concat
                        (VecMAC
                          (VecMAC
                            (Vec4
                              0
                              0
                              (+ (* v10 v3) (* v9 v4))
                              (+
                                (* v2 v12)
                                (* v11 v3)
                                (* v10 v4)
                                (* v9 v5)))
                            (Vec4 0 v0 v1 v1)
                            (Vec4 0 v12 v12 v13))
                          (Vec4 v11 v9 v0 v0)
                          (Vec4 v2 v3 v13 v14))
                        (Concat
                          (VecMAC
                            (VecMAC
                              (VecMAC
                                (Vec4
                                  (* v11 v4)
                                  0
                                  0
                                  (+ (* v12 v4) (* v10 v6) (* v9 v7)))
                                (Vec4 v10 0 v12 v3)
                                (Vec4 v5 0 v3 v13))
                              (Vec4 v2 v11 v9 v0)
                              (Vec4 v13 v5 v6 v16))
                            (Vec4 v1 v2 v0 v1)
                            (Vec4 v14 v14 v15 v15))
                          (Concat
                            (VecMAC
                              (VecMAC
                                (VecMAC
                                  (Vec4
                                    (+
                                      (* v3 v14)
                                      (* v13 v4)
                                      (* v12 v5)
                                      (* v11 v6)
                                      (* v10 v7)
                                      (* v9 v8))
                                    (+ (* v13 v5) (* v11 v7) (* v10 v8))
                                    0
                                    0)
                                  (Vec4 v2 v4 v11 0)
                                  (Vec4 v15 v14 v8 0))
                                (Vec4 v1 v2 v2 v12)
                                (Vec4 v16 v16 v17 v6))
                              (Vec4 v0 v1 v14 v3)
                              (Vec4 v17 v17 v5 v15))
                            (Concat
                              (VecMAC
                                (VecMAC
                                  (VecAdd
                                    (VecMAC
                                      (VecMul
                                        (Vec4 0 v13 0 0)
                                        (Vec4 0 v7 0 0))
                                      (Vec4 v13 v8 v14 0)
                                      (Vec4 v6 v12 v7 0))
                                    (VecMAC
                                      (VecMul
                                        (Vec4 0 v5 0 0)
                                        (Vec4 0 v15 0 0))
                                      (Vec4 v12 v14 v13 0)
                                      (Vec4 v7 v6 v8 0)))
                                  (Vec4 v15 v16 v17 v8)
                                  (Vec4 v4 v4 v4 v14))
                                (Vec4 v3 v3 v5 v5)
                                (Vec4 v16 v17 v16 v17))
                              (Concat
                                (VecMAC
                                  (VecMAC
                                    (VecMul
                                      (Vec4 0 0 v16 0)
                                      (Vec4 0 0 v7 0))
                                    (Vec4 0 v6 v15 v7)
                                    (Vec4 0 v16 v8 v17))
                                  (Vec4 v15 v15 v6 v16)
                                  (Vec4 v6 v7 v17 v8))
                                (List (* v17 v8))))))))";
    let exp_best_cost = 350.906;
    run_egpraph_with_start(start, exp_best, exp_best_cost);
  }
}

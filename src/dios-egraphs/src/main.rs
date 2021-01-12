pub mod binopsearcher;
pub mod config;
pub mod cost;
pub mod macsearcher;
pub mod rewriteconcats;
pub mod rules;
pub mod searchutils;
pub mod stringconversion;
pub mod veclang;

extern crate clap;
use clap::{App, Arg};

fn main() {
    let matches = App::new("Diospyros Rewriter")
        .arg(
            Arg::with_name("INPUT")
                .help("Sets the input file")
                .required(true)
                .index(1),
        )
        .arg(
            Arg::with_name("no-ac")
                .long("no-ac")
                .help("Disable associativity and commutativity rules"),
        )
        .arg(
            Arg::with_name("no-vec")
                .long("no-vec")
                .help("Disable vector rules"),
        )
        .get_matches();

    use std::{env, fs};

    // Get a path string to parse a program.
    let path = matches.value_of("INPUT").unwrap();
    let timeout = env::var("TIMEOUT")
        .ok()
        .and_then(|t| t.parse::<u64>().ok())
        .unwrap_or(180);
    let prog_str = fs::read_to_string(path).expect("Failed to read the input file.");

    // AST conversion: boxed Rosette terms to Egg syntax
    let converted: String = stringconversion::convert_string(&prog_str)
        .expect("Failed to convert the input file to egg AST.");

    // Rewrite a list of expressions to a concatenation of vectors
    let concats = rewriteconcats::list_to_concats(&converted);
    let prog = concats.unwrap().parse().unwrap();

    // Rules to disable flags
    let no_ac = matches.is_present("no-ac");
    let no_vec = matches.is_present("no-vec");

    // Run rewriter
    eprintln!(
        "Running egg with timeout {:?}s, width: {:?}",
        timeout,
        config::vector_width()
    );
    let (cost, best) = rules::run(&prog, timeout, no_ac, no_vec);

    println!("{}", best.pretty(80)); /* Pretty print with width 80 */
    eprintln!("\nCost: {}", cost);
}

#[cfg(test)]
mod tests {

    use super::{rules::*, veclang::VecLang};
    use assert_approx_eq::assert_approx_eq;
    use egg::*;

    fn run_egpraph_with_start(prog: &str, exp_best: &str, exp_best_cost: f64) {
        // AST conversion: boxed Rosette terms to Egg syntax
        let converted: String = super::stringconversion::convert_string(&prog.to_string())
            .expect("Failed to convert the input file to egg AST.");

        // Rewrite a list of expressions to a concatenation of vectors
        let concats = super::rewriteconcats::list_to_concats(&converted);
        let start = concats.unwrap().parse().unwrap();

        // Run with AC off
        let (best_cost, best) = run(&start, 60, true, false);

        println!(
            "original:\n{}\nbest:\n{}\nbest cost {}",
            start.pretty(80),
            best.pretty(80),
            best_cost,
        );
        if best != exp_best.parse().unwrap() {
            println!(
                "Expected best not equal:{}",
                exp_best.parse::<RecExpr<VecLang>>().unwrap().pretty(80)
            );
        }
        assert_approx_eq!(best_cost, exp_best_cost, 0.000001);
    }

    #[test]
    fn simple_vector_add() {
        let start = "(Vec (+ a b) (+ c d) 0 0)";
        let exp_best = "(VecAdd (Vec a c 0 0) (Vec b d 0 0))";
        let exp_best_cost = 1.208;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn vector_pairwise_mac() {
        let start = "
      (Vec
        (+ (* a b) (+ (* c d) (* e f)))
        (+ (* aa bb) (+ (* cc dd) (* ee ff)))
        0
        0)";
        let exp_best = "
      (VecMAC
        (VecMAC
          (VecMul (Vec c aa 0 0) (Vec d bb 0 0))
          (Vec e ee 0 0)
          (Vec f ff 0 0))
        (Vec a cc 0 0)
        (Vec b dd 0 0))";
        let exp_best_cost = 3.624;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn qr_decomp_snippet() {
        let start = "
      (Vec
        (*
          (neg (sgn (Get A 0)))
          (sqrt
            (+
              (* (Get A 0) (Get A 0))
              (* (Get A 2) (Get A 2)))))
        (*
          (neg (sgn (Get A 0)))
          (sqrt
            (+
              (* (Get A 0) (Get A 0))
              (* (Get A 2) (Get A 2)))))
        (*
          (neg (sgn (Get A 0)))
          (sqrt
            (+
              (* (Get A 0) (Get A 0))
              (* (Get A 2) (Get A 2)))))
        (Get A 2))";
        let _best_with_ac = "
      ((VecMul
        (VecNeg (Vec (sgn (Get A 0)) (sgn (Get A 0)) (sgn (Get A 0)) (neg 1)))
        (Vec
          (sqrt (+ (* (Get A 0) (Get A 0)) (* (Get A 2) (Get A 2))))
          (sqrt (+ (* (Get A 0) (Get A 0)) (* (Get A 2) (Get A 2))))
          (sqrt (+ (* (Get A 0) (Get A 0)) (* (Get A 2) (Get A 2))))
          (Get A 2)))";
        let exp_best_cost = 18.249;

        // No rewrites found with AC off
        run_egpraph_with_start(start, start, exp_best_cost);
    }

    #[test]
    fn vector_variadic_add_mac() {
        let start = "
      (Vec
        (+ (* a b) (* c d) (* e f))
        (+ (* aa bb) (* cc dd) (* ee ff))
        0
        0)";
        let exp_best = "
      (VecMAC
        (VecMAC
          (VecMul (Vec e ee 0 0) (Vec f ff 0 0))
          (Vec c cc 0 0)
          (Vec d dd 0 0))
        (Vec a aa 0 0)
        (Vec b bb 0 0))";
        let exp_best_cost = 3.624;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn vector_mac() {
        let start = "
      (Vec (+ ?a0 (* ?b0 ?c0))
           (+ ?a1 (* ?b1 ?c1))
           (+ ?a2 (* ?b2 ?c2))
           (+ ?a3 (* ?b3 ?c3)))";
        let exp_best = "
      (VecMAC (Vec ?a0 ?a1 ?a2 ?a3)
              (Vec ?b0 ?b1 ?b2 ?b3)
              (Vec ?c0 ?c1 ?c2 ?c3))";
        let exp_best_cost = 1.312;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn vector_mac_just_mul_or_zero() {
        let start = "
      (Vec (+ ?a0 (* ?b0 ?c0))
            (* ?b1 ?c1)
            0
            (+ ?a3 (* ?b3 ?c3)))";
        let exp_best = "
      (VecMAC (Vec ?a0 0 0 ?a3)
              (Vec ?b0 ?b1 0 ?b3)
              (Vec ?c0 ?c1 0 ?c3))";
        let exp_best_cost = 1.312;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn vector_matrix_multiply_2x2_2x2() {
        let start = "
      (Vec
        (+ (* v0 v4) (* v1 v6))
        (+ (* v0 v5) (* v1 v7))
        (+ (* v2 v4) (* v3 v6))
        (+ (* v2 v5) (* v3 v7)))";
        let exp_best = "
      (VecMAC
        (VecMul
          (Vec v1 v1 v6 v7)
          (Vec v6 v7 v3 v3))
        (Vec v4 v5 v2 v2)
        (Vec v0 v0 v4 v5))";
        let exp_best_cost = 2.416;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn vector_matrix_multiply_2x2_2x2_explicit_get() {
        let start = "
      (Vec
        (+ (* (Get a 0) (Get b 0)) (* (Get a 1) (Get b 2)))
        (+ (* (Get a 0) (Get b 1)) (* (Get a 1) (Get b 3)))
        (+ (* (Get a 2) (Get b 0)) (* (Get a 3) (Get b 2)))
        (+ (* (Get a 2) (Get b 1)) (* (Get a 3) (Get b 3))))";
        let exp_best = "
      (VecMAC
        (VecMul
          (LitVec (Get a 0) (Get a 0) (Get a 2) (Get a 2))
          (LitVec (Get b 0) (Get b 1) (Get b 0) (Get b 1)))
        (LitVec (Get a 1) (Get a 1) (Get a 3) (Get a 3))
        (LitVec (Get b 2) (Get b 3) (Get b 2) (Get b 3)))";
        let exp_best_cost = 2.052;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn vector_matrix_multiply_2x3_3x3() {
        let start = "
      (List
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
        let exp_best = "
      (Concat
        (VecMAC
          (VecMAC
            (VecMul
              (LitVec (Get A 1) (Get A 1) (Get A 1) (Get A 4))
              (LitVec (Get B 3) (Get B 4) (Get B 5) (Get B 3)))
            (LitVec (Get A 2) (Get A 2) (Get A 2) (Get A 5))
            (LitVec (Get B 6) (Get B 7) (Get B 8) (Get B 6)))
          (LitVec (Get A 0) (Get A 0) (Get A 0) (Get A 3))
          (LitVec (Get B 0) (Get B 1) (Get B 2) (Get B 0)))
        (VecMAC
          (VecMAC
            (VecMul (Vec (Get A 4) (Get A 4) 1 1) (LitVec (Get B 4) (Get B 5) 0 0))
            (Vec (Get A 5) (Get A 5) 1 1)
            (LitVec (Get B 7) (Get B 8) 0 0))
          (LitVec (Get A 3) (Get A 3) 0 0)
          (LitVec (Get B 1) (Get B 2) 0 0)))";
        let exp_best_cost = 6.43;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn vector_2d_conv_2x2_2x2() {
        let start = "
      (List
        (* v0 v4)
        (+ (* v0 v5) (* v1 v4))
        (* v1 v5)
        (+ (* v0 v6) (* v2 v4))
        (+ (* v0 v7) (* v1 v6) (* v2 v5) (* v3 v4))
        (+ (* v1 v7) (* v3 v5))
        (* v2 v6)
        (+ (* v2 v7) (* v3 v6))
        (* v3 v7))";
        let exp_best = "
      (Concat
        (VecMAC
          (VecMul (Vec 1 v0 1 v0) (Vec 0 v5 0 v6))
          (Vec v0 v1 v1 v2)
          (Vec v4 v4 v5 v4))
        (Concat
          (VecMAC
            (VecAdd
              (VecMul (Vec v1 1 1 1) (Vec v6 0 0 0))
              (VecMAC
                (VecMul (Vec v2 1 1 1) (Vec v5 0 0 0))
                (Vec v3 v1 1 v2)
                (Vec v4 v7 0 v7)))
            (Vec v0 v3 v2 v3)
            (Vec v7 v5 v6 v6))
          (VecMul (Vec v3 0 0 0) (Vec v7 0 0 0))))";
        let exp_best_cost = 9.656;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }

    #[test]
    fn vector_2d_conv_3x3_3x3() {
        let start = "(Concat
      (Vec
        (* v0 v9)
        (+ (* v0 v10) (* v1 v9))
        (+ (* v0 v11) (* v1 v10) (* v2 v9))
        (+ (* v1 v11) (* v2 v10)))
      (Concat
        (Vec
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
          (Vec
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
            (Vec
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
              (Vec
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
                (Vec
                  (* v6 v15)
                  (+ (* v6 v16) (* v7 v15))
                  (+ (* v6 v17) (* v7 v16) (* v8 v15))
                  (+ (* v7 v17) (* v8 v16)))
                (List
                  (* v8 v17))))))))";
        let exp_best = "
    (Vec
      (VecMAC
        (VecMAC
          (VecMul (Vec 1 1 v1 1) (Vec 0 0 v10 0))
          (Vec 1 v0 v2 v1)
          (Vec 0 v10 v9 v11))
        (Vec v0 v1 v0 v2)
        (Vec v9 v9 v11 v10))
      (Concat
        (VecMAC
          (VecAdd
            (VecMul (Vec 1 1 1 v1) (Vec 0 0 0 v13))
            (VecAdd
              (VecMul (Vec 1 1 1 v2) (Vec 0 0 0 v12))
              (VecAdd
                (VecMul (Vec 1 1 v1 v3) (Vec 0 0 v12 v11))
                (VecMAC
                  (VecMul (Vec 1 1 v3 v4) (Vec 0 0 v10 v10))
                  (Vec 1 v0 v4 v5)
                  (Vec 0 v12 v9 v9)))))
          (Vec v2 v3 v0 v0)
          (Vec v11 v9 v13 v14))
        (Concat
          (VecMAC
            (VecAdd
              (VecMul (Vec 1 1 1 v1) (Vec 0 0 0 v15))
              (VecAdd
                (VecMul (Vec 1 1 1 v3) (Vec 0 0 0 v13))
                (VecAdd
                  (VecMul (Vec v2 1 1 v4) (Vec v13 0 0 v12))
                  (VecMAC
                    (VecMul (Vec v4 1 v3 v6) (Vec v11 0 v12 v10))
                    (Vec v5 v2 v6 v7)
                    (Vec v10 v14 v9 v9)))))
            (Vec v1 v5 v0 v0)
            (Vec v14 v11 v15 v16))
          (Concat
            (VecMAC
              (VecAdd
                (VecMul (Vec v1 1 1 1) (Vec v16 0 0 0))
                (VecAdd
                  (VecMul (Vec v2 1 1 1) (Vec v15 0 0 0))
                  (VecAdd
                    (VecMul (Vec v3 1 1 1) (Vec v14 0 0 0))
                    (VecAdd
                      (VecMul (Vec v4 v2 1 1) (Vec v13 v16 0 0))
                      (VecAdd
                        (VecMul (Vec v5 v4 1 1) (Vec v12 v14 0 0))
                        (VecAdd
                          (VecMul (Vec v6 v5 1 1) (Vec v11 v13 0 0))
                          (VecMAC
                            (VecMul (Vec v7 v7 v5 1) (Vec v10 v11 v14 0))
                            (Vec v8 v8 v8 v3)
                            (Vec v9 v10 v11 v15))))))))
              (Vec v0 v1 v2 v6)
              (Vec v17 v17 v17 v12))
            (Concat
              (VecMAC
                (VecAdd
                  (VecMul (Vec 1 v4 1 1) (Vec 0 v16 0 0))
                  (VecAdd
                    (VecMul (Vec 1 v5 1 1) (Vec 0 v15 0 0))
                    (VecAdd
                      (VecMul (Vec v4 v6 v5 1) (Vec v15 v14 v16 0))
                      (VecMAC
                        (VecMul (Vec v6 v7 v7 1) (Vec v13 v13 v14 0))
                        (Vec v7 v8 v8 v5)
                        (Vec v12 v12 v13 v17)))))
                (Vec v3 v3 v4 v8)
                (Vec v16 v17 v17 v14))
              (Concat
                (VecMAC
                  (VecMAC
                    (VecMul (Vec 1 1 v7 1) (Vec 0 0 v16 0))
                    (Vec 1 v6 v8 v7)
                    (Vec 0 v16 v15 v17))
                  (Vec v6 v7 v6 v8)
                  (Vec v15 v15 v17 v16))
                (List (* v8 v17)))))))
      0
      0)";
        let exp_best_cost = 156.468;
        run_egpraph_with_start(start, exp_best, exp_best_cost);
    }
}

#lang rosette

(require rosette/solver/smt/z3)

(provide (all-defined-out))

; All configurations for the Diospyros compiler.

; Solver to use
(current-solver (z3))

; Reasoning precision for values
(define value-fin
  (make-parameter 20))

; BV length for representing indices in shuffle vectors
(define index-fin
  (make-parameter 20))

; BV length for representing the program cost
(define cost-fin
  (make-parameter 20))

; Egg intermediate files
(define-values (egg-spec egg-prelude egg-outputs egg-res)
  (values "spec" "prelude" "outputs" "res"))

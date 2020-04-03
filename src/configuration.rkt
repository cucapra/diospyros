#lang rosette

(require rosette/solver/smt/boolector)

(provide (all-defined-out))

; All configurations for the Diospyros compiler.

; Solver to use
(current-solver (boolector))

; Reasoning precision for values
(define value-fin
  (make-parameter 5))

; BV length for representing indices in shuffle vectors
(define index-fin
  (make-parameter 6))

; BV length for representing the program cost
(define cost-fin
  (make-parameter 10))

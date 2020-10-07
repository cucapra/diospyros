#lang rosette

(require "ast.rkt"
         "backend/tensilica-g3.rkt"
         "c-ast.rkt"
         "compile-passes.rkt"
         "dsp-insts.rkt"
         "verify.rkt"
         "interp.rkt"
         "prog-sketch.rkt"
         "register-allocation-pass.rkt"
         "shuffle-truncation-pass.rkt"
         "utils.rkt"
         rackunit
         rackunit/text-ui)

(provide compile
         check-transform-with-fn-map)

; When not #f, uses the fn-map to verify the programs.
(define check-transform-with-fn-map (make-parameter #f))

(define (allocate-and-truncate prog)
  ; Make binding environment for register allocation.
  (define env (make-hash))
  (define alloc-prog (register-allocation prog env))
  (define trunc-prog (shuffle-truncation alloc-prog env))
  trunc-prog)

;; Compile a vector program into an executable C++ program
(define (compile p #:spec [spec #f])

  ; Add optimization passes like const elimination.
  (define ssa-prog (ssa p))
  (define elim-prog (const-elim ssa-prog))
  (define lvn-prog (lvn elim-prog))
  (define trunc-prog (allocate-and-truncate lvn-prog))

  (when (check-transform-with-fn-map)
    (pretty-display "Running translation validation")
    (assert
      (equal?
        (unsat)
        (verify-spec-prog spec
                          (to-v-list-prog trunc-prog)
                          #:fn-map (check-transform-with-fn-map)))))
  trunc-prog)

#lang rosette

(require "ast.rkt"
         "backend/tensilica-g3.rkt"
         "c-ast.rkt"
         "compile-passes.rkt"
         "dsp-insts.rkt"
         "synth.rkt"
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
(define (compile p)

  ; Add optimization passes like const elimination.
  (define ssa-prog (ssa p))
  (define elim-prog (const-elim ssa-prog))
  (define trunc-prog (allocate-and-truncate elim-prog))

  (when (check-transform-with-fn-map)
    (assert
      (equal?
        (unsat)
        (verify-prog p
                     trunc-prog
                     #:fn-map (check-transform-with-fn-map)))))

  trunc-prog)

(define matrix-multiply
  (prog
    (list
      (vec-extern-decl 'A 6 input-tag)
      (vec-extern-decl 'B 9 input-tag)
      (vec-extern-decl 'C 6 output-tag)
      (vec-const 'Z '#(0))
      (vec-const 'shuf0-0 '#(3 3 1 0))
      (vec-const 'shuf1-0 '#(1 2 2 2))
      (vec-const 'shuf2-0 '#(4 5 6 7))
      (vec-shuffle 'reg-A 'shuf0-0 '(A Z))
      (vec-shuffle 'reg-B 'shuf1-0 '(B Z))
      (vec-shuffle 'reg-C 'shuf2-0 '(C))
      (vec-void-app 'continuous-aligned-vec? '(shuf2-0))
      (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
      (vec-shuffle-set! 'C 'shuf2-0 'out)
      (vec-const 'shuf0-1 '#(4 4 4 5))
      (vec-const 'shuf1-1 '#(4 5 7 6))
      (vec-const 'shuf2-1 '#(4 5 6 7))
      (vec-shuffle 'reg-A 'shuf0-1 '(A Z))
      (vec-shuffle 'reg-B 'shuf1-1 '(B Z))
      (vec-shuffle 'reg-C 'shuf2-1 '(C))
      (vec-void-app 'continuous-aligned-vec? '(shuf2-1))
      (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
      (vec-shuffle-set! 'C 'shuf2-1 'out)
      (vec-const 'shuf0-2 '#(0 0 0 4))
      (vec-const 'shuf1-2 '#(0 1 2 3))
      (vec-const 'shuf2-2 '#(0 1 2 3))
      (vec-shuffle 'reg-A 'shuf0-2 '(A Z))
      (vec-shuffle 'reg-B 'shuf1-2 '(B Z))
      (vec-shuffle 'reg-C 'shuf2-2 '(C))
      (vec-void-app 'continuous-aligned-vec? '(shuf2-2))
      (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
      (vec-shuffle-set! 'C 'shuf2-2 'out)
      (vec-const 'shuf0-3 '#(5 5 5 4))
      (vec-const 'shuf1-3 '#(7 8 6 5))
      (vec-const 'shuf2-3 '#(4 5 6 7))
      (vec-shuffle 'reg-A 'shuf0-3 '(A Z))
      (vec-shuffle 'reg-B 'shuf1-3 '(B Z))
      (vec-shuffle 'reg-C 'shuf2-3 '(C))
      (vec-void-app 'continuous-aligned-vec? '(shuf2-3))
      (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
      (vec-shuffle-set! 'C 'shuf2-3 'out)
      (vec-const 'shuf0-4 '#(2 1 2 5))
      (vec-const 'shuf1-4 '#(6 4 8 6))
      (vec-const 'shuf2-4 '#(0 1 2 3))
      (vec-shuffle 'reg-A 'shuf0-4 '(A Z))
      (vec-shuffle 'reg-B 'shuf1-4 '(B Z))
      (vec-shuffle 'reg-C 'shuf2-4 '(C))
      (vec-void-app 'continuous-aligned-vec? '(shuf2-4))
      (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
      (vec-shuffle-set! 'C 'shuf2-4 'out)
      (vec-const 'shuf0-5 '#(1 2 1 3))
      (vec-const 'shuf1-5 '#(3 7 5 0))
      (vec-const 'shuf2-5 '#(0 1 2 3))
      (vec-shuffle 'reg-A 'shuf0-5 '(A Z))
      (vec-shuffle 'reg-B 'shuf1-5 '(B Z))
      (vec-shuffle 'reg-C 'shuf2-5 '(C))
      (vec-void-app 'continuous-aligned-vec? '(shuf2-5))
      (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
      (vec-shuffle-set! 'C 'shuf2-5 'out))))

(define 2d-conv
  (prog
    (list
      (vec-extern-decl 'I 9 input-tag)
      (vec-extern-decl 'O 9 output-tag)
      (vec-extern-decl 'F 4 input-tag)
      (vec-const 'Z '#(0))
      (vec-const 'shuf0-0 '#(8 8 11 8))
      (vec-const 'shuf1-0 '#(3 3 3 3))
      (vec-const 'shuf2-0 '#(8 9 10 11))
      (vec-shuffle 'reg-I 'shuf0-0 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-0 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-0 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-0))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-0 'out)
      (vec-const 'shuf0-1 '#(4 5 6 7))
      (vec-const 'shuf1-1 '#(0 0 5 0))
      (vec-const 'shuf2-1 '#(0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-1 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-1 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-1 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-1))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-1 'out)
      (vec-const 'shuf0-2 '#(5 12 14 14))
      (vec-const 'shuf1-2 '#(2 2 1 2))
      (vec-const 'shuf2-2 '#(4 5 6 7))
      (vec-shuffle 'reg-I 'shuf0-2 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-2 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-2 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-2))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-2 'out)
      (vec-const 'shuf0-3 '#(10 4 5 6))
      (vec-const 'shuf1-3 '#(5 1 5 1))
      (vec-const 'shuf2-3 '#(0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-3 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-3 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-3 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-3))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-3 'out)
      (vec-const 'shuf0-4 '#(3 7 15 8))
      (vec-const 'shuf1-4 '#(1 5 2 7))
      (vec-const 'shuf2-4 '#(0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-4 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-4 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-4 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-4))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-4 'out)
      (vec-const 'shuf0-5 '#(7 5 7 7))
      (vec-const 'shuf1-5 '#(1 5 2 7))
      (vec-const 'shuf2-5 '#(4 5 6 7))
      (vec-shuffle 'reg-I 'shuf0-5 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-5 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-5 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-5))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-5 'out)
      (vec-const 'shuf0-6 '#(8 8 11 8))
      (vec-const 'shuf1-6 '#(0 1 1 2))
      (vec-const 'shuf2-6 '#(4 5 6 7))
      (vec-shuffle 'reg-I 'shuf0-6 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-6 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-6 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-6))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-6 'out)
      (vec-const 'shuf0-7 '#(4 5 6 7))
      (vec-const 'shuf1-7 '#(3 3 3 3))
      (vec-const 'shuf2-7 '#(4 5 6 7))
      (vec-shuffle 'reg-I 'shuf0-7 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-7 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-7 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-7))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-7 'out)
      (vec-const 'shuf0-8 '#(1 2 5 4))
      (vec-const 'shuf1-8 '#(2 2 1 2))
      (vec-const 'shuf2-8 '#(0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-8 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-8 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-8 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-8))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-8 'out)
      (vec-const 'shuf0-9 '#(0 1 2 3))
      (vec-const 'shuf1-9 '#(3 3 3 3))
      (vec-const 'shuf2-9 '#(0 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-9 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-9 '(F Z))
      (vec-shuffle 'reg-O 'shuf2-9 '(O))
      (vec-void-app 'continuous-vec? '(shuf2-9))
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-shuffle-set! 'O 'shuf2-9 'out))))

(module+ test
  (run-tests
    (test-suite
      "compile tests"
      (test-case
        "compiler runs"
        (to-string (tensilica-g3-compile (compile 2d-conv))))
      (test-case
        "Mat mul example"

        (define fn-map
          (hash 'vec-mac
                vector-mac
                'continuous-aligned-vec?
                (curry continuous-aligned-vec?
                       (current-reg-size))))

        (check-equal? (unsat) (verify-prog matrix-multiply
                                           (compile matrix-multiply)
                                           #:fn-map fn-map))))))

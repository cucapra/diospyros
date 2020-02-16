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
      (vec-extern-decl 'A 6)
      (vec-extern-decl 'B 9)
      (vec-extern-decl 'C 6)
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

(define 2d-conv-writes
  (prog
    (list
      (vec-extern-decl 'I 16)
      (vec-extern-decl 'O 16)
      (vec-extern-decl 'F 4)
      (vec-const 'Z '#(0))
      (vec-load 'O_0_4 'O 0 4)
      (vec-load 'O_4_8 'O 4 8)
      (vec-load 'O_8_12 'O 8 12)
      (vec-load 'O_12_16 'O 12 16)
      (vec-const 'shuf0-0 '#(5 2 7 3))
      (vec-const 'shuf1-0 '#(0 2 0 4))
      (vec-shuffle 'reg-I 'shuf0-0 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-0 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_0_4)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_0_4 'out)
      (vec-const 'shuf0-1 '#(1 1 6 4))
      (vec-const 'shuf1-1 '#(2 5 1 5))
      (vec-shuffle 'reg-I 'shuf0-1 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-1 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_0_4)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_0_4 'out)
      (vec-const 'shuf0-2 '#(9 5 7 8))
      (vec-const 'shuf1-2 '#(0 3 2 7))
      (vec-shuffle 'reg-I 'shuf0-2 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-2 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_4_8)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_4_8 'out)
      (vec-const 'shuf0-3 '#(4 6 2 7))
      (vec-const 'shuf1-3 '#(1 0 3 1))
      (vec-shuffle 'reg-I 'shuf0-3 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-3 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_0_4)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_0_4 'out)
      (vec-const 'shuf0-4 '#(0 5 3 3))
      (vec-const 'shuf1-4 '#(3 1 2 3))
      (vec-shuffle 'reg-I 'shuf0-4 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-4 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_0_4)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_0_4 'out)
      (vec-const 'shuf0-5 '#(8 6 6 7))
      (vec-const 'shuf1-5 '#(1 2 3 3))
      (vec-shuffle 'reg-I 'shuf0-5 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-5 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_4_8)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_4_8 'out)
      (vec-const 'shuf0-6 '#(4 10 10 11))
      (vec-const 'shuf1-6 '#(3 0 1 1))
      (vec-shuffle 'reg-I 'shuf0-6 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-6 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_4_8)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_4_8 'out)
      (vec-const 'shuf0-7 '#(13 13 14 11))
      (vec-const 'shuf1-7 '#(2 3 3 5))
      (vec-shuffle 'reg-I 'shuf0-7 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-7 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_12_16)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_12_16 'out)
      (vec-const 'shuf0-8 '#(12 14 15 15))
      (vec-const 'shuf1-8 '#(3 2 2 3))
      (vec-shuffle 'reg-I 'shuf0-8 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-8 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_12_16)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_12_16 'out)
      (vec-const 'shuf0-9 '#(8 10 14 2))
      (vec-const 'shuf1-9 '#(3 2 1 4))
      (vec-shuffle 'reg-I 'shuf0-9 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-9 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_8_12)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_8_12 'out)
      (vec-const 'shuf0-10 '#(13 14 10 15))
      (vec-const 'shuf1-10 '#(0 0 3 1))
      (vec-shuffle 'reg-I 'shuf0-10 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-10 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_8_12)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_8_12 'out)
      (vec-const 'shuf0-11 '#(12 9 15 11))
      (vec-const 'shuf1-11 '#(1 3 0 3))
      (vec-shuffle 'reg-I 'shuf0-11 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-11 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_8_12)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_8_12 'out)
      (vec-const 'shuf0-12 '#(2 1 3 15))
      (vec-const 'shuf1-12 '#(6 3 6 7))
      (vec-shuffle 'reg-I 'shuf0-12 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-12 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_0_4)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_0_4 'out)
      (vec-const 'shuf0-13 '#(9 13 11 15))
      (vec-const 'shuf1-13 '#(2 1 2 7))
      (vec-shuffle 'reg-I 'shuf0-13 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-13 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_8_12)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_8_12 'out)
      (vec-const 'shuf0-14 '#(5 9 11 8))
      (vec-const 'shuf1-14 '#(2 1 0 7))
      (vec-shuffle 'reg-I 'shuf0-14 '(I Z))
      (vec-shuffle 'reg-F 'shuf1-14 '(F Z))
      (vec-decl 'reg-O 4)
      (vec-write 'reg-O 'O_4_8)
      (vec-app 'out 'vec-mac '(reg-O reg-I reg-F))
      (vec-write 'O_4_8 'out)
      (vec-store 'O 'O_0_4 0 4)
      (vec-store 'O 'O_4_8 4 8)
      (vec-store 'O 'O_8_12 8 12)
      (vec-store 'O 'O_12_16 12 16))))

(display (to-string (tensilica-g3-compile (compile 2d-conv-writes))))

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
                                           #:fn-map fn-map)))

      (test-case
        "2d-conv example"
        (define fn-map
          (hash 'vec-mac
                vector-mac)
        (check-equal? (unsat) (verify-prog 2d-conv-writes
                                           (compile 2d-conv-writes)
                                           #:fn-map fn-map)))))))

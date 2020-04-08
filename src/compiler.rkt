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
  (define concrete-prog (concretize-bv-lists p))
  (define ssa-prog (ssa concrete-prog))
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
    (vec-extern-decl 'A 6 'extern-input)
    (vec-extern-decl 'B 9 'extern-input)
    (vec-extern-decl 'C 6 'extern-output)
    (vec-decl 'reg-C 4)
    (vec-load 'C_0_4 'C (bv #b000000 6) (bv #b000100 6))
    (vec-load 'C_4_8 'C (bv #b000100 6) (bv #b001000 6))
    (vec-const
     'shuf0-0
     '(#&(bv #b000000 6) #&(bv #b000010 6) #&(bv #b000001 6) #&(bv #b000101 6)))
    (vec-const
     'shuf1-0
     '(#&(bv #b000000 6) #&(bv #b000111 6) #&(bv #b000101 6) #&(bv #b000110 6)))
    (vec-shuffle 'reg-A 'shuf0-0 '(A))
    (vec-shuffle 'reg-B 'shuf1-0 '(B))
    (vec-write 'reg-C 'C_0_4)
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-write 'C_0_4 'out)
    (vec-const
     'shuf0-1
     '(#&(bv #b000001 6) #&(bv #b000001 6) #&(bv #b000010 6) #&(bv #b000100 6)))
    (vec-const
     'shuf1-1
     '(#&(bv #b000011 6) #&(bv #b000100 6) #&(bv #b001000 6) #&(bv #b000011 6)))
    (vec-shuffle 'reg-A 'shuf0-1 '(A))
    (vec-shuffle 'reg-B 'shuf1-1 '(B))
    (vec-write 'reg-C 'C_0_4)
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-write 'C_0_4 'out)
    (vec-const
     'shuf0-2
     '(#&(bv #b000100 6) #&(bv #b000011 6) #&(bv #b000100 6) #&(bv #b000100 6)))
    (vec-const
     'shuf1-2
     '(#&(bv #b000100 6) #&(bv #b000010 6) #&(bv #b000010 6) #&(bv #b000010 6)))
    (vec-shuffle 'reg-A 'shuf0-2 '(A))
    (vec-shuffle 'reg-B 'shuf1-2 '(B))
    (vec-write 'reg-C 'C_4_8)
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-write 'C_4_8 'out)
    (vec-const
     'shuf0-3
     '(#&(bv #b000011 6) #&(bv #b000100 6) #&(bv #b000001 6) #&(bv #b000001 6)))
    (vec-const
     'shuf1-3
     '(#&(bv #b000001 6) #&(bv #b000101 6) #&(bv #b001000 6) #&(bv #b001000 6)))
    (vec-shuffle 'reg-A 'shuf0-3 '(A))
    (vec-shuffle 'reg-B 'shuf1-3 '(B))
    (vec-write 'reg-C 'C_4_8)
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-write 'C_4_8 'out)
    (vec-const
     'shuf0-4
     '(#&(bv #b000101 6) #&(bv #b000101 6) #&(bv #b000001 6) #&(bv #b000001 6)))
    (vec-const
     'shuf1-4
     '(#&(bv #b000111 6) #&(bv #b001000 6) #&(bv #b000110 6) #&(bv #b000111 6)))
    (vec-shuffle 'reg-A 'shuf0-4 '(A))
    (vec-shuffle 'reg-B 'shuf1-4 '(B))
    (vec-write 'reg-C 'C_4_8)
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-write 'C_4_8 'out)
    (vec-const
     'shuf0-5
     '(#&(bv #b000010 6) #&(bv #b000000 6) #&(bv #b000000 6) #&(bv #b000011 6)))
    (vec-const
     'shuf1-5
     '(#&(bv #b000110 6) #&(bv #b000001 6) #&(bv #b000010 6) #&(bv #b000000 6)))
    (vec-shuffle 'reg-A 'shuf0-5 '(A))
    (vec-shuffle 'reg-B 'shuf1-5 '(B))
    (vec-write 'reg-C 'C_0_4)
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-write 'C_0_4 'out)
    (vec-store 'C 'C_0_4 (bv #b000000 6) (bv #b000100 6))
    (vec-store 'C 'C_4_8 (bv #b000100 6) (bv #b001000 6)))))

;(display (to-string (tensilica-g3-compile (compile 2d-conv-writes))))

(module+ test
  (run-tests
    (test-suite
      "compile tests"
      (test-case
        "compiler runs"
        (to-string (tensilica-g3-compile (compile matrix-multiply))))

      (test-case
        "Mat mul example"
        (define fn-map
          (hash 'vec-mac vector-mac))
        (check-equal? (unsat) (verify-prog matrix-multiply
                                           (compile matrix-multiply)
                                           #:fn-map fn-map)))

      ; (test-case
      ;   "2d-conv example"
      ;   (define fn-map (hash 'vec-mac vector-mac))
      ;   (check-equal? (unsat) (verify-prog 2d-conv-writes
      ;                                     (compile 2d-conv-writes)
      ;                                     #:fn-map fn-map)))
      ; (test-case
      ;   "2d-conv 3x3 2x2"
      ;   (define input
      ;     (vector 0 1 2
      ;             3 4 5
      ;             6 7 8))
      ;   (define filter
      ;     (vector 0 1
      ;             2 3))
      ;   (define gold
      ;     (vector 0  0  1  2
      ;             0  5  11 11
      ;             6  23 29 23
      ;             12 32 37 24))
      ;   (define-values (env _ )
      ;     (interp (compile 2d-conv-3x3-2x2)
      ;       #:fn-map (hash 'vec-mac vector-mac)
      ;       (list (cons 'I input)
      ;             (cons 'F filter)
      ;             (cons 'O (make-vector (vector-length gold) 0)))))
      ;   (check-equal? (hash-ref env `O)
      ;                 gold))
      )))

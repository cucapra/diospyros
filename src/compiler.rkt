#lang rosette

(require "ast.rkt"
         "register-allocation-pass.rkt"
         "shuffle-truncation-pass.rkt"
         "compile-passes.rkt"
         "backend/tensilica-g3.rkt")

;; Compile a vector program into an executable C++ program
(define (compile p)
  ; Make binding environment for register allocation.
  (define env (make-hash))

  ; Add optimization passes like const elimination.
  (define ssa-prog (ssa p))
  (define elim-prog (const-elim ssa-prog))
  ;(pretty-print ssa-prog)
  (define alloc-prog (register-allocation elim-prog env))
  (define trunc-prog (shuffle-truncation alloc-prog env))

  trunc-prog)

(define p
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

(pretty-print (tensilica-g3-compile (compile p) (list 'A 'B) (list 'C)))

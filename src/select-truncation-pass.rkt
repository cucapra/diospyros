#lang racket

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "matrix-utils.rkt"
         "register-allocation-pass.rkt")

(provide (all-defined-out))

; Determines registers used and sorts ascending
(define (ordered-regs-used reg-size shufs)
  (sort (remove-duplicates (map (curry reg-of reg-size)
                                (vector->list shufs))) <))

; Truncates shuffles to reference only the accessed registers.
; reg-size 4,  [0, 1, 8, 9] -> [0, 1, 2, 3]
(define (truncate-shuf reg-size ordered-regs-used i)
  (let* ([mod (modulo i reg-size)]
        [reg (reg-of reg-size i)]
        [offset (* (index-of ordered-regs-used reg) reg-size)])
    (+ mod offset)))

(define (shuffle-or-select env reg-size id idxs inps)
  (define shufs (hash-ref env idxs))
  (define ordered-regs (ordered-regs-used reg-size shufs))

  (define truncated-shufs (vector-map (curry truncate-shuf reg-size ordered-regs) shufs))

  (match (length ordered-regs)
    [1
     (let ([source-id (hash-ref (hash-ref env (first inps)) (first ordered-regs))])
       (vec-shuffle id id source-id))]
    [2
     ; Otherwise, it's a shuffle between two loads
     ; TODO: handle nesting correctly
     (define reg-ids (map (curry hash-ref env inps) ordered-regs))
     (apply vec-select id id reg-ids)]))
  

; Produces 1 or more instructions, modifies env
(define (truncate-select-inst env reg-size inst)
  (match inst
    [(vec-shuffle id idxs inp)
     (shuffle-or-select env reg-size id idxs (list inp))]
    [(vec-select id idxs inp1 inp2)
     (shuffle-or-select env reg-size id idxs (list inp1 inp2))]
    [_ inst]))

(define (select-truncation program env reg-size)
  (define instrs (flatten (map (curry truncate-select-inst env reg-size)
                               (prog-insts program))))
  ;(pretty-print env)
  (prog instrs))

; Test program copied from matmul
(define p (prog
 (list
  (vec-extern-decl 'A 6)
  (vec-extern-decl 'B 9)
  (vec-extern-decl 'C 6)
  (vec-const 'X '#(0 1 2 3 4 5))
  (vec-const 'Z '#(0))
  (vec-const `shuf-fake '#(0 1 2 4))
  (vec-const 'shuf0-0 '#(3 1 3 3))
  (vec-const 'shuf1-0 '#(1 3 2 0))
  (vec-const 'shuf2-0 '#(4 0 5 3))
  (vec-select 'reg-A 'shuf0-0 'A 'Z)
  (vec-select 'reg-B 'shuf1-0 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-0 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-0 'out)
  (vec-const 'shuf0-1 '#(4 0 0 0))
  (vec-const 'shuf1-1 '#(3 2 1 0))
  (vec-const 'shuf2-1 '#(3 2 1 0))
  (vec-select 'reg-A 'shuf0-1 'A 'Z)
  (vec-select 'reg-B 'shuf1-1 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-1 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-1 'out)
  (vec-const 'shuf0-2 '#(5 4 6 5))
  (vec-const 'shuf1-2 '#(8 4 5 6))
  (vec-const 'shuf2-2 '#(5 4 0 3))
  (vec-select 'reg-A 'shuf0-2 'A 'Z)
  (vec-select 'reg-B 'shuf1-2 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-2 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-2 'out)
  (vec-const 'shuf0-3 '#(2 2 2 2))
  (vec-const 'shuf1-3 '#(6 9 7 8))
  (vec-const 'shuf2-3 '#(0 3 1 2))
  (vec-select 'reg-A 'shuf0-3 'A 'Z)
  (vec-select 'reg-B 'shuf1-3 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-3 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-3 'out)
  (vec-const 'shuf0-4 '#(4 5 1 1))
  (vec-const 'shuf1-4 '#(5 7 5 4))
  (vec-const 'shuf2-4 '#(5 4 2 1))
  (vec-select 'reg-A 'shuf0-4 'A 'Z)
  (vec-select 'reg-B 'shuf1-4 'B 'Z)
  (vec-shuffle 'reg-C 'shuf2-4 'C)
  (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
  (vec-shuffle-set! 'C 'shuf2-4 'out))))

(define env (make-hash))
(define reg-size 4)
(define reg-alloc (register-allocation p env reg-size))

(pretty-print (select-truncation reg-alloc env reg-size))
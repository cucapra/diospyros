#lang racket

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "matrix-utils.rkt"
         "prog-sketch.rkt"
         "register-allocation-pass.rkt")

(provide (all-defined-out))

(define reg-limit 2)

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

; Map an index to either the input it references, or the allocated register
; that now holds that index value
(define (inp-id-for-idx env inps idx)
  (cond
    [(empty? inps) (error "idx ~a not found in inputs") idx]
    [else
     (define inp-id (first inps))
     (define inp-val (hash-ref env inp-id))
     (cond
       ; The input is a constant
       [(vector? inp-val)
        (define const-len (vector-length inp-val))
        (cond
          ; Our index falls inside the constant vector
          [(< idx const-len) inp-id]
          ; Otherwise, on to the next input
          [else
           (inp-id-for-idx env (rest inps) (- idx const-len))])]
       ; Input has been mapped across allocated registers
       [else
        (cond
          ; The mapped input symbol
          [(hash-has-key? inp-val idx) (hash-ref inp-val idx)]
          ; Otherwise, on to the next input
          [else
           (define hash-len (length (hash->list inp-val)))
           (inp-id-for-idx env (rest inps) (- idx hash-len))])])]))

(define (nest-shuffles reg-size shufs id idxs inp-ids new-inps)
  (define input-count (length new-inps))
  (cond
    ; We only touch 2 registers, and are done nesting
    [(<= input-count reg-limit) (vec-shuffle id idxs new-inps)]
    ; Otherwise, combine the first two inputs into a temporary register
    [else
     (define new-shuf-id
       (string->symbol (format "~a-tmp-~a" idxs input-count)))
     (define tmp-id
       (string->symbol (format "~a-tmp-~a" id input-count)))
     (define new-shuf (make-vector reg-size 0))
     (for ([i (in-range reg-size)])
       (define idx (vector-ref shufs i))
       (cond
         [(< idx (* reg-limit reg-size))
          (vector-set! new-shuf i idx)
          (vector-set! shufs i i)]
         [else
          (vector-set! shufs i (- idx reg-size))]))
     (define shuf-decl (vec-const new-shuf-id new-shuf))
     (define tmp-shuf (vec-shuffle tmp-id new-shuf-id (take new-inps 2)))
     (cons shuf-decl (cons tmp-shuf
           (nest-shuffles reg-size shufs id idxs inp-ids (cons tmp-id (drop new-inps 2)))))]))

(define (shuffle-or-select env reg-size id idxs inps)
  (define shufs (hash-ref env idxs))
  (define ordered-regs (ordered-regs-used reg-size shufs))
  (define num-regs (length ordered-regs))

  ; Get the allocated register each index falls within
  (define inp-ids
    (map (curry inp-id-for-idx env inps) (vector->list shufs)))
  (define new-inps (remove-duplicates inp-ids))

  ; Truncate indices based on the register they fall within
  (for ([i (in-range (length inp-ids))])
    (let* ([inp-id (list-ref inp-ids i)]
           [position (index-of new-inps inp-id)]
           [idx (vector-ref shufs i)]
           [trunc (+ (modulo idx reg-size) (* position reg-size))])
      (vector-set! shufs i trunc)))

  ; Handle cases that require nesting
  (nest-shuffles reg-size shufs id idxs inp-ids new-inps))

; Produces 1 or more instructions, modifies env
(define (truncate-select-inst env reg-size inst)
  (match inst
    [(vec-shuffle id idxs inps)
     (shuffle-or-select env reg-size id idxs inps)]
    [_ inst]))

(define (select-truncation program env reg-size)
  (define instrs (flatten (map (curry truncate-select-inst env reg-size)
                               (prog-insts program))))
  ;(pretty-print env)
  (prog instrs))

; Test program copied from matmul
(define p
  (prog
   (list
    (vec-extern-decl 'A 6)
    (vec-extern-decl 'B 9)
    (vec-extern-decl 'C 6)
    (vec-const 'Z '#(0))
    (vec-const 'shuf0-0 '#(0 3 1 5))
    (vec-const 'shuf1-0 '#(0 2 5 6))
    (vec-const 'shuf2-0 '#(0 5 2 3))
    (vec-shuffle 'reg-A 'shuf0-0 '(A Z))
    (vec-shuffle 'reg-B 'shuf1-0 '(B Z))
    (vec-shuffle 'reg-C 'shuf2-0 '(C))
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-shuffle-set! 'C 'shuf2-0 'out)
    (vec-const 'shuf0-1 '#(2 4 2 4))
    (vec-const 'shuf1-1 '#(6 5 8 3))
    (vec-const 'shuf2-1 '#(0 5 2 3))
    (vec-shuffle 'reg-A 'shuf0-1 '(A Z))
    (vec-shuffle 'reg-B 'shuf1-1 '(B Z))
    (vec-shuffle 'reg-C 'shuf2-1 '(C))
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-shuffle-set! 'C 'shuf2-1 'out)
    (vec-const 'shuf0-2 '#(2 4 2 4))
    (vec-const 'shuf1-2 '#(7 12 12 4))
    (vec-const 'shuf2-2 '#(1 3 0 4))
    (vec-shuffle 'reg-A 'shuf0-2 '(A Z))
    (vec-shuffle 'reg-B 'shuf1-2 '(B Z))
    (vec-shuffle 'reg-C 'shuf2-2 '(C))
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-shuffle-set! 'C 'shuf2-2 'out)
    (vec-const 'shuf0-3 '#(0 3 1 5))
    (vec-const 'shuf1-3 '#(1 0 3 7))
    (vec-const 'shuf2-3 '#(1 3 0 4))
    (vec-shuffle 'reg-A 'shuf0-3 '(A Z))
    (vec-shuffle 'reg-B 'shuf1-3 '(B Z))
    (vec-shuffle 'reg-C 'shuf2-3 '(C))
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-shuffle-set! 'C 'shuf2-3 'out)
    (vec-const 'shuf0-4 '#(0 3 1 5))
    (vec-const 'shuf1-4 '#(2 1 4 8))
    (vec-const 'shuf2-4 '#(2 4 1 5))
    (vec-shuffle 'reg-A 'shuf0-4 '(A Z))
    (vec-shuffle 'reg-B 'shuf1-4 '(B Z))
    (vec-shuffle 'reg-C 'shuf2-4 '(C))
    (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
    (vec-shuffle-set! 'C 'shuf2-4 'out))))

(define c-env (make-hash))
(define reg-size 4)
(define reg-alloc (register-allocation p c-env reg-size))

(define new-prog (select-truncation reg-alloc c-env reg-size))
(pretty-print new-prog)

(match-define (matrix A-rows A-cols A-elements) (make-symbolic-matrix 2 3))
(match-define (matrix B-rows B-cols B-elements) (make-symbolic-matrix 3 3))
(define env (make-hash))
(hash-set! env 'A A-elements)
(hash-set! env 'B B-elements)
(hash-set! env 'C (make-vector (* A-rows B-cols) 0))

(pretty-print (interp new-prog env #:fn-map (hash 'vec-mac vector-mac)))
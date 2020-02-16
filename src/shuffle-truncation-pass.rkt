#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "utils.rkt"
         "prog-sketch.rkt"
         "register-allocation-pass.rkt"
         threading)

(provide shuffle-truncation)

; Number of registers the target can run select on.
(define reg-limit 2)

; Fresh name generation for new variables
(define new-var (make-name-gen))

; Map an index to either the input it references, or the allocated register
; that now holds that index value
(define (inp-id-for-idx env inps idx)
  (assert (not (empty? inps))
          (format "idx ~a not found in inputs" idx))
  (define inp-id (first inps))
  (define inp-val (hash-ref env inp-id))
  (cond
    ; The input is a constant
    [(vector? inp-val)
     (define const-len (vector-length inp-val))
     (if (< idx const-len)
       inp-id
       (inp-id-for-idx env (rest inps) (- idx const-len)))]
    ; Input has been mapped across allocated registers
    [else
      (cond
        ; The mapped input symbol
        [(hash-has-key? inp-val idx) (hash-ref inp-val idx)]
        ; Otherwise, on to the next input
        [else
          (define hash-len (length (hash->list inp-val)))
          (inp-id-for-idx env (rest inps) (- idx hash-len))])]))

; Handle cases where shuffles touch more registers than the limit
(define (nest-shuffles shufs id idxs inp-ids new-inps)
  (define input-count (length new-inps))
  (cond
    ; We only touch 2 registers, and are done nesting
    [(<= input-count reg-limit) (vec-shuffle id idxs new-inps)]
    ; Otherwise, combine the first two inputs into a temporary register
    [else
     ; Create a new temp register.
     (define new-shuf-id (new-var idxs))
     (define tmp-id (new-var (format "~a_tmp" id)))
     (define new-shuf (make-vector (current-reg-size) 0))

     (for ([i (in-range (current-reg-size))])
       (define idx (vector-ref shufs i))
       (cond
         [(< idx (* reg-limit (current-reg-size)))
          (vector-set! new-shuf i idx)
          (vector-set! shufs i i)]
         [else
          (vector-set! shufs i (- idx (current-reg-size)))]))

     ; New shuffle idxs for shuffling into the temp register.
     (define shuf-decl (vec-const new-shuf-id new-shuf))
     (define tmp-shuf (vec-shuffle tmp-id new-shuf-id (take new-inps 2)))

     (list
       shuf-decl
       tmp-shuf
       (nest-shuffles shufs id idxs inp-ids
                      (cons tmp-id (drop new-inps 2))))]))

(define (truncate-irregular-shuffle env id idxs inps)
  ; Declare a new shuffle vector to modify
  (define shufs (hash-ref env idxs))
  (define shuf-id (new-var idxs))
  (define shuf-vec (vector-copy shufs))
  (define shuf-decl (vec-const shuf-id shuf-vec))

  ; Get the allocated register each index falls within
  (define inp-ids
    (map (curry inp-id-for-idx env inps) (vector->list shuf-vec)))
  (define new-inps (remove-duplicates inp-ids))

  ; Truncate indices based on the register they fall within
  (for ([i (in-range (length inp-ids))])
    (let* ([inp-id (list-ref inp-ids i)]
           [position (index-of new-inps inp-id)]
           [idx (vector-ref shuf-vec i)]
           [trunc (+ (modulo idx (current-reg-size))
                     (* position (current-reg-size)))])
      (vector-set! shuf-vec i trunc)))

  ; Handle cases that require nesting
  (cons shuf-decl (nest-shuffles shuf-vec id shuf-id inp-ids new-inps)))

(define (shuffle-to-write env id shufs inp)
  (define val (hash-ref env inp))
  (define src
    (cond
      ; The input is a constant
      [(vector? val) inp]
      ; The input has been mapped across allocated registers
      [else (hash-ref val (vector-ref shufs 0))]))
  (list
    (vec-decl id (current-reg-size))
    (vec-write id src)))

(define (truncate-shuffle env id idxs inps)
  (define shufs (hash-ref env idxs))
  (if (and (is-continuous-aligned-vec? (current-reg-size) shufs)
           (eq? (length inps) 1))
      (shuffle-to-write env id shufs (first inps))
      (truncate-irregular-shuffle env id idxs inps)))


(define (truncate-shuffle-set env out-vec idxs inp)
  (define shufs (hash-ref env idxs))
  (assert (continuous-aligned-vec? (current-reg-size) shufs)
          (format "Shuffle-set ~a must be continuous and aligned" shufs))

  (define out-val (hash-ref env out-vec))
  (define dest
    (cond
      ; The output is a constant
      [(vector? out-val)
       out-vec]
      ; Output has been mapped across allocated registers
      [else (hash-ref out-val (vector-ref shufs 0))]))

  (vec-write dest inp))

; Produces 1 or more instructions, modifies env
(define (truncate-shuffle-inst env inst)
  (match inst
    [(vec-shuffle id idxs inps)
     (truncate-shuffle env id idxs inps)]
    [(vec-shuffle-set! out-vec idxs inp)
     (truncate-shuffle-set env out-vec idxs inp)]
    [_ inst]))

(define (shuffle-truncation program env)
  (~> (curry truncate-shuffle-inst env )
      (map _ (prog-insts program))
      flatten
      prog))

(module+ test
  (require rackunit
           rackunit/text-ui)

  ; Test program copied from matmul
  (define p
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

  (run-tests
   (test-suite
    "shuffle truncation tests"
    (test-case
     "Mat mul example"
     (define c-env (make-hash))
     (define reg-alloc (register-allocation p c-env))

     (define new-prog (shuffle-truncation reg-alloc c-env))

     (match-define (matrix A-rows A-cols A-elements) (make-symbolic-matrix 2 3))
     (match-define (matrix B-rows B-cols B-elements) (make-symbolic-matrix 3 3))

     (check-equal? (length (prog-insts new-prog)) 90)

     (define (make-env)
       (define env (make-hash))
       (hash-set! env 'A A-elements)
       (hash-set! env 'B B-elements)
       (hash-set! env 'C (make-vector (* A-rows B-cols) 0))
       env)

     (define-values (gold-env gold-cost)
       (interp p (make-env)
               #:fn-map (hash 'vec-mac
                              vector-mac
                              'continuous-aligned-vec?
                              (curry continuous-aligned-vec? (current-reg-size)))))
     (define gold-C (vector-take (hash-ref gold-env 'C) 6))

     (define-values (new-env new-cost)
       (interp new-prog (make-env)
               #:fn-map (hash 'vec-mac
                              vector-mac
                              'continuous-aligned-vec?
                              (curry continuous-aligned-vec? (current-reg-size)))))
     (define new-C (vector-take (hash-ref new-env 'C) 6))

     (check-equal? gold-C new-C)))))

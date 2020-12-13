#lang rosette

(require "ast.rkt"
         "dsp-insts.rkt"
         "interp.rkt"
         "utils.rkt"
         "prog-sketch.rkt"
         "register-allocation-pass.rkt"
         "translation-validation.rkt"
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
     (define shuf-decl (vec-const new-shuf-id new-shuf int-type))
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
  (define shuf-decl (vec-const shuf-id shuf-vec int-type))

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
           (equal? (length inps) 1))
      (shuffle-to-write env id shufs (first inps))
      (truncate-irregular-shuffle env id idxs inps)))


(define (truncate-shuffle-set env out-vec idxs inp)
  (define shufs (hash-ref env idxs))
  (assert (is-continuous-aligned-vec? (current-reg-size) shufs)
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
  (~> (curry truncate-shuffle-inst env)
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
        (vec-extern-decl 'A 6 'extern-input)
        (vec-extern-decl 'B 9 'extern-input)
        (vec-extern-decl 'C 6 'extern-output)
        (vec-decl 'reg-C 4)
        (vec-load 'C_0_4 'C 0 4)
        (vec-load 'C_4_8 'C 4 8)
        (vec-const 'shuf0-0 '#(3 5 2 5) int-type)
        (vec-const 'shuf1-0 '#(1 8 2 2) int-type)
        (vec-shuffle 'reg-A 'shuf0-0 '(A))
        (vec-shuffle 'reg-B 'shuf1-0 '(B))
        (vec-write 'reg-C 'C_4_8)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-write 'C_4_8 'out)
        (vec-const 'shuf0-1 '#(2 2 0 4) int-type)
        (vec-const 'shuf1-1 '#(6 7 2 3) int-type)
        (vec-shuffle 'reg-A 'shuf0-1 '(A))
        (vec-shuffle 'reg-B 'shuf1-1 '(B))
        (vec-write 'reg-C 'C_0_4)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-write 'C_0_4 'out)
        (vec-const 'shuf0-2 '#(1 1 2 3) int-type)
        (vec-const 'shuf1-2 '#(3 4 8 0) int-type)
        (vec-shuffle 'reg-A 'shuf0-2 '(A))
        (vec-shuffle 'reg-B 'shuf1-2 '(B))
        (vec-write 'reg-C 'C_0_4)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-write 'C_0_4 'out)
        (vec-const 'shuf0-3 '#(0 0 1 5) int-type)
        (vec-const 'shuf1-3 '#(0 1 5 6) int-type)
        (vec-shuffle 'reg-A 'shuf0-3 '(A))
        (vec-shuffle 'reg-B 'shuf1-3 '(B))
        (vec-write 'reg-C 'C_0_4)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-write 'C_0_4 'out)
        (vec-const 'shuf0-4 '#(5 4 2 4) int-type)
        (vec-const 'shuf1-4 '#(7 5 2 3) int-type)
        (vec-shuffle 'reg-A 'shuf0-4 '(A))
        (vec-shuffle 'reg-B 'shuf1-4 '(B))
        (vec-write 'reg-C 'C_4_8)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-write 'C_4_8 'out)
        (vec-const 'shuf0-5 '#(4 3 0 0) int-type)
        (vec-const 'shuf1-5 '#(4 2 6 3) int-type)
        (vec-shuffle 'reg-A 'shuf0-5 '(A))
        (vec-shuffle 'reg-B 'shuf1-5 '(B))
        (vec-write 'reg-C 'C_4_8)
        (vec-app 'out 'vec-mac '(reg-C reg-A reg-B))
        (vec-write 'C_4_8 'out)
        (vec-store 'C 'C_0_4 0 4)
        (vec-store 'C 'C_4_8 4 8))))

  (run-tests
   (test-suite
    "shuffle truncation tests"
    (test-case
     "Mat mul example"
     (define c-env (make-hash))
     (define reg-alloc (register-allocation p c-env))

     (define new-prog (shuffle-truncation reg-alloc c-env))
     (define fn-map (hash 'vec-mac vector-mac))

     (check-equal? (length (prog-insts new-prog)) 74)))))

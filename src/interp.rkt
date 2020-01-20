#lang rosette

(require "dsp-insts.rkt"
         "ast.rkt"
         "matrix-utils.rkt"
         "prog-sketch.rkt"
         rosette/lib/match)

(provide (all-defined-out))

; Read a vector of `size` starting at location `start` from `memory`
(define (read-vec memory start size)
  (vector-copy memory start (+ start size)))

; Write a vector to `memory` to the location `start` and return the updated
; memory.
; MUTATES the argument `memory`.
(define (write-vec! memory start vec)
  (vector-copy! memory start vec))

(define (default-fn-defns f)
  (raise (format "attempt to apply undefined function ~a" f)))

; Interpretation function that takes a program and an external memory.
; MUTATES the memory in place during program interpretation.
; Returns the cost of the program using `cost-fn`.
; `cost-fn` takes an instruction returns an integer value describing the cost
; of the instruction. It ASSUMES that the instruction does not contain any free
; variables.
; `fn-defns` is an optional argument to provide external function definitions
(define (interp program
                memory
                #:cost-fn [cost-fn (thunk* 0)]
                #:fn-map [fn-map default-fn-defns])
  ; The environment mapping for the program.
  (define env (make-hash))
  (define (env-set! key val)
    (hash-set! env key val))
  (define (env-ref key)
    (hash-ref env key))

  ; Track the cost of the program
  (define cur-cost 0)
  (define (incr-cost! val)
    (set! cur-cost (+ cur-cost val)))

  (for ([inst (prog-insts program)])
    ;(pretty-print `(,inst ,memory))
    (define inst-cost
      (match inst
        [(vec-load id start size)
         (env-set! id (read-vec memory start size))
         (cost-fn inst)]
        [(vec-unload id start)
         (write-vec! memory start (env-ref id))
         (cost-fn inst)]
        [(vec-const id init)
         (env-set! id init)
         (cost-fn inst)]
        [(vec-shuffle id idxs inp)
         (let ([inp-val (env-ref inp)]
               [idxs-val (env-ref idxs)])
           (env-set! id (vector-shuffle inp-val idxs-val))
           ; Pass a deferenced version of vec-shuffle to cost-fn
           (cost-fn (vec-shuffle id idxs-val inp-val)))]
        [(vec-select id idxs inp1 inp2)
         (let ([inp1-val (env-ref inp1)]
               [inp2-val (env-ref inp2)]
               [idxs-val (env-ref idxs)])
           (env-set! id (vector-select inp1-val inp2-val idxs-val))
           (cost-fn (vec-select id inp1-val inp2-val idxs-val)))]
        [(vec-shuffle-set! out-vec idxs inp)
         (let ([out-vec-val (env-ref out-vec)]
               [inp-val (env-ref inp)]
               [idxs-val (env-ref idxs)])
           (vector-shuffle-set! out-vec-val idxs-val inp-val)
           (cost-fn (vec-shuffle-set! out-vec-val idxs-val inp-val)))]
        [(vec-app id f inps)
         (let ([inps-val (map env-ref inps)]
               [fn (hash-ref fn-map f)])
           (env-set! id (apply fn inps-val))
           (cost-fn (vec-app id f inps-val)))]
        [(vec-print id)
         (pretty-print (env-ref id))
         (cost-fn inst)]
        [_ (assert #f (~a "unknown instruction " inst))]))

    (incr-cost! inst-cost))

  cur-cost)


; Cost of a program is the sum of the registers touched by each indices vector
; passed to a shuffle-like instruction.
(define (simple-shuffle-cost reg-upper-bound inst)
  (match inst
    [(or (vec-shuffle _ idxs _)
         (vec-select _ idxs _ _)
         (vec-shuffle-set! _ idxs _))
     (reg-used idxs (current-reg-size) reg-upper-bound)]
    [_ 0]))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "interp tests"
      (test-case
        "Write out constant vector"
        (define memory
          (make-vector 4 0))
        (define gold
          (vector 1 2 3 4))
        (define/prog p
          ('x = vec-const gold)
          (vec-unload 'x 0))
        (interp p memory)
        (check-equal? (read-vec memory 0 4) gold))

      (test-case
        "create shuffled vector"
        (define memory
          (make-vector 4 0))
        (define gold
          (vector 3 1 2 0))
        (define/prog p
          ('const = vec-const (vector 0 1 2 3))
          ('idxs = vec-const (vector 3 1 2 0))
          ('shuf = vec-shuffle 'idxs 'const)
          (vec-unload 'shuf 0))
        (interp p memory)
        (check-equal? (read-vec memory 0 4) gold))

      (test-case
        "simple-shuffle-cost calculates cost correctly"
        (define/prog p
          ('a = vec-const (vector 0 1 2 3 4 5 6 7))
          ('b = vec-const (vector 8 9 10 11 12 13 14 15))
          ('i1 = vec-const (vector 1 4 7 5))
          ('i2 = vec-const (vector 0 3 2 1))
          ('i3 = vec-const (vector 0 1 8 9))
          ('s1 = vec-shuffle 'i1 'a)
          ('s2 = vec-shuffle 'i2 'a)
          ('s2 = vec-select 'i3 'a 'b))
        (check-equal?
          (interp p
                  (make-vector 4)
                  (curry simple-shuffle-cost 2)) 5)
        ; cost depends on the current-reg-size
        (parameterize ([current-reg-size 2])
          (check-equal?
            (interp p
                    (make-vector 4)
                    (curry simple-shuffle-cost 4)) 9)))

      )))

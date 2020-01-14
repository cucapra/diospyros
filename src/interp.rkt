#lang rosette

(require "dsp-insts.rkt"
         "ast.rkt"
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

; Interpretation function that takes a program and an external memory.
; Returns a vector representing the state of the final memory.
(define (interp program memory)
  (define env (make-hash))
  (define (env-set! key val)
    (hash-set! env key val))
  (define (env-ref key)
    (hash-ref env key))

  (for ([inst (prog-insts program)])
    (match inst
      [(vec-load id start size)
       (env-set! id (read-vec memory start size))]
      [(vec-unload id start)
       (write-vec! memory start (env-ref id))]
      [(vec-const id init)
       (env-set! id init)]
      [(vec-shuffle id inp idxs)
       (env-set! id
                 (vector-shuffle (env-ref inp)
                                 (env-ref idxs)))]
      [(vec-select id inp1 inp2 idxs)
       (env-set! id (vector-select
                     (env-ref inp1)
                     (env-ref inp2)
                     (env-ref idxs)))]
      [(vec-shuffle-set! out-vec inp idxs)
       (vector-shuffle-set!
        (env-ref out-vec)
        (env-ref inp)
        (env-ref idxs))]
      [(vec-app id f inps)
       (env-set! id (apply f (map env-ref inps)))]))

  memory)

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
          ('shuf = vec-shuffle 'const 'idxs)
          (vec-unload 'shuf 0))
        (interp p memory)
        (check-equal? (read-vec memory 0 4) gold))

      )))

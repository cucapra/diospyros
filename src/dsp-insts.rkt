#lang rosette

(require rackunit
         rackunit/text-ui)

(provide vector-shuffle)

;; Define set of instructions commonly found in DSP architectures.

;; VECTOR SHUFFLE
(define (vector-shuffle inp idxs)
  (for/vector ([idx idxs])
    (assert (< idx (vector-length inp))
            "VECTOR-SHUFFLE: idx larger than elements in input vector")
    (vector-ref inp idx)))

(define vector-shuffle-tests
  (test-suite
    "shuffle tests"
    (test-case
      "vector shuffle basic example"
      (let ([inp (vector 0 1 2 3 4)]
            [idxs (vector 1 1 0 3 4 2)]
            [gold (vector 1 1 0 3 4 2)])
        (check-equal? gold (vector-shuffle inp idxs))))

    (test-case
      "synthesize indices"
      (define idxs-gold (vector 6 2 4 3))
      (define-symbolic* idxs-lst integer? [4])
      (define idxs (list->vector idxs-lst))
      (define inp (vector 10 11 22 5 7 14 6))
      (define out-gold (vector 6 22 7 5))
      (define idxs-synth
        (evaluate
          idxs
          (solve (assert (equal? (vector-shuffle inp idxs) out-gold)))))
      (check-equal? idxs-gold idxs-synth))))

(define (vector-select inp1 inp2 idxs)
  (vector-shuffle (vector-append inp1 inp2) idxs))

(define vector-select-tests
  (test-suite
    "select tests"
    (test-case
      "vector select basic example"
      (let ([inp1 (vector 0 1 2 3)]
            [inp2 (vector 10 11 12 13)]
            [idxs (vector 7 7 0 3 2 5)]
            [gold (vector 13 13 0 3 2 11)])
        (check-equal? gold (vector-select inp1 inp2 idxs))))))

(run-tests vector-shuffle-tests)
(run-tests vector-select-tests)

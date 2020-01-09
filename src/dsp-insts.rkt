#lang rosette

(require rackunit
         rackunit/text-ui)

;; Define set of instructions commonly found in DSP architectures.

;; VECTOR SHUFFLE
(define (vector-shuffle inp idxs out)
  (assert (eq? (vector-length idxs) (vector-length out)))
  (for ([idx idxs]
        [out-idx (in-range (vector-length out))])
    (assert (< idx (vector-length inp)))
    (vector-set! out out-idx (vector-ref inp idx)))
  out)

(define vector-shuffle-tests
  (test-suite
    "shuffle tests"
    (test-case
      "vector shuffle basic example"
    (let ([inp (vector 0 1 2 3 4)]
          [idxs (vector 1 1 0 3 4 2)]
          [out  (vector 0 0 0 0 0 0)]
          [gold (vector 1 1 0 3 4 2)])
      (check-equal? gold (vector-shuffle inp idxs out))))))



(run-tests vector-shuffle-tests)

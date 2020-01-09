#lang rosette

(require rackunit
         rackunit/text-ui)

(provide vector-shuffle)

;; Define set of instructions commonly found in DSP architectures.

;; VECTOR SHUFFLE
; The implementation differs from the actual instruction in that this allows
; us to specify the output matrix.
(define (vector-shuffle inp idxs out)
  (assert (eq? (vector-length idxs) (vector-length out))
          "VECTOR-SHUFFLE: mismatch in length of idxs and out")
  (for ([idx idxs]
        [out-idx (in-range (vector-length out))])
    (assert (< idx (vector-length inp))
            "VECTOR-SHUFFLE: idx larger than elements in input vector")
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
        (check-equal? gold (vector-shuffle inp idxs out))))

    (test-case
      "synthesize indices"
      (define idxs-gold (vector 6 2 4 3))
      (define-symbolic* idxs-lst integer? [4])
      (define idxs (list->vector idxs-lst))
      (define inp (vector 10 11 22 5 7 14 6))
      (define out-gold (vector 6 22 7 5))
      (define out (vector 0 0 0 0))
      (vector-shuffle inp idxs out)
      (define idxs-synth
        (evaluate
          idxs
          (solve (assert (equal? out out-gold)))))
      (check-equal? idxs-gold idxs-synth))))

(run-tests vector-shuffle-tests)

#lang rosette

(require rackunit
         rackunit/text-ui)

(provide vector-shuffle
         vector-shuffle-set!
         vector-select
         vector-multiply
         vector-mac)

;; Define set of instructions commonly found in DSP architectures.

;; VECTOR SHUFFLE
(define (vector-shuffle inp idxs)
  (for/vector ([idx idxs])
    (assert (< idx (vector-length inp))
            "VECTOR-SHUFFLE: idx larger than elements in input vector")
    (vector-ref inp idx)))

;; VECTOR-SHUFFLE-STORE: store vals[i] into out-vec[idxs[i]]
(define (vector-shuffle-set! out-vec idxs vals)
  (assert (= (vector-length idxs) (vector-length vals))
          "VECTOR-SHUFFLE-SET: length mismatch")
  (assert (<= (vector-length idxs) (vector-length out-vec))
          "VECTOR-SHUFFLE-SET: idxs is larger than out-vec")
  (assert (apply distinct? (vector->list idxs))
          "VECTOR-SHUFFLE-SET: duplicate indices")
  (for ([idx idxs]
        [val vals])
    (vector-set! out-vec idx val))
  out-vec)

;; VECTOR SELECT
(define (vector-select inp1 inp2 idxs)
  (vector-shuffle (vector-append inp1 inp2) idxs))

;; VECTOR MULTIPLY
(define (vector-multiply v1 v2)
  (assert (= (vector-length v1) (vector-length v2))
          "VECTOR-MULTIPLY: length of vectors not equal")
  (for/vector ([e1 v1]
               [e2 v2])
    (* e1 e2)))

;; VECTOR-MAC
(define (vector-mac v-acc v1 v2)
  (assert (= (vector-length v1)
             (vector-length v2)
             (vector-length v-acc))
          "VECTOR-MAC: length of vectors not equal")
  (for/vector ([e-acc v-acc]
               [e1 v1]
               [e2 v2])
    (+ e-acc (* e1 e2))))

(define dsp-insts-tests
  (test-suite
    "DSP instructions tests"
    (test-case
      "VECTOR-SHUFFLE: basic example"
      (let ([inp (vector 0 1 2 3 4)]
            [idxs (vector 1 1 0 3 4 2)]
            [gold (vector 1 1 0 3 4 2)])
        (check-equal? (vector-shuffle inp idxs) gold)))

    (test-case
      "VECTOR-SHUFFLE: synthesize indices"
      (define idxs-gold (vector 6 2 4 3))
      (define-symbolic* idxs-lst integer? [4])
      (define idxs (list->vector idxs-lst))
      (define inp (vector 10 11 22 5 7 14 6))
      (define out-gold (vector 6 22 7 5))
      (define idxs-synth
        (evaluate
          idxs
          (solve (assert (equal? (vector-shuffle inp idxs) out-gold)))))
      (check-equal? idxs-synth idxs-gold))

    (test-case
      "VECTOR-SELECT basic example"
      (let ([inp1 (vector 0 1 2 3)]
            [inp2 (vector 10 11 12 13)]
            [idxs (vector 7 7 0 3 2 5)]
            [gold (vector 13 13 0 3 2 11)])
        (check-equal? (vector-select inp1 inp2 idxs) gold)))

    (test-case
      "VECTOR-SHUFFLE-SET: basic example"
      (let ([out-vec (vector 0 0 0 0)]
            [vals (vector 10 11 12 13)]
            [idxs (vector 3 1 0 2)]
            [gold (vector 12 11 13 10)])
        (check-equal? (vector-shuffle-set! out-vec idxs vals) gold)))
    ))

(module+ test
  (run-tests dsp-insts-tests))

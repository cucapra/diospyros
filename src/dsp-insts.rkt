#lang rosette

(require "utils.rkt"
         "configuration.rkt"
         rackunit
         racket/trace
         rackunit/text-ui)

(provide vector-shuffle
         vector-shuffle-set!
         vector-multiply
         vector-mac)

;; Define set of instructions commonly found in DSP architectures.

;; VECTOR SHUFFLE: return (append inps)[idxs[i]].
(define (vector-shuffle inps idxs)
  (assert (list? idxs) "Expected list")
  (assert (list? inps) "Expected list")
  (define all-inp (apply append inps))
  (for/list ([idx idxs])
    (assert (bvslt (unbox idx)
                   (bitvectorize-concrete (index-fin)
                                          (length all-inp)))
            (format "VECTOR-SHUFFLE: idx ~a larger than elements in input vector ~a" idx all-inp))
    (box (bv-list-get all-inp (unbox idx)))))

;; VECTOR-SHUFFLE-SET!: store vals[i] into out-vec[idxs[i]]
(define (vector-shuffle-set! out-vec idxs vals)
  (assert (= (length idxs) (length vals))
          "VECTOR-SHUFFLE-SET: length mismatch")
  (assert (<= (length idxs) (length out-vec))
          "VECTOR-SHUFFLE-SET: idxs is larger than out-vec")
  (assert (apply distinct? (vector->list idxs))
          "VECTOR-SHUFFLE-SET: duplicate indices")
  (for ([idx idxs]
        [val vals])
    (bv-list-set! out-vec idx val))
  out-vec)

;; VECTOR MULTIPLY
(define (vector-multiply v1 v2)
  (assert (= (length v1) (length v2))
          "VECTOR-MULTIPLY: length of vectors not equal")
  (for/vector ([e1 v1]
               [e2 v2])
    (bvmul e1 e2)))

;; VECTOR-MAC
(define (vector-mac v-acc v1 v2)
  (assert (= (length v1)
             (length v2)
             (length v-acc))
          "VECTOR-MAC: length of vectors not equal")
  (for/vector ([e-acc v-acc]
               [e1 v1]
               [e2 v2])
    (bvadd e-acc (bvmul e1 e2))))

(define dsp-insts-tests
  (test-suite
    "DSP instructions tests"
    (test-case
      "VECTOR-SHUFFLE: basic example, one register"
      (let ([inp (vector 0 1 2 3 4)]
            [idxs (vector 1 1 0 3 4 2)]
            [gold (vector 1 1 0 3 4 2)])
        (check-equal? (vector-shuffle (list inp) idxs) gold)))

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
          (solve (assert (equal? (vector-shuffle (list inp) idxs) out-gold)))))
      (check-equal? idxs-synth idxs-gold))

    (test-case
      "VECTOR-SHUFFLE: basic example, multiple registers"
      (let ([inp1 (vector 0 1 2 3)]
            [inp2 (vector 10 11 12 13)]
            [idxs (vector 7 7 0 3 2 5)]
            [gold (vector 13 13 0 3 2 11)])
        (check-equal? (vector-shuffle (list inp1 inp2) idxs) gold)))

    (test-case
      "VECTOR-SHUFFLE-SET: basic example, one register"
      (let ([out-vec (vector 0 0 0 0)]
            [vals (vector 10 11 12 13)]
            [idxs (vector 3 1 0 2)]
            [gold (vector 12 11 13 10)])
        (check-equal? (vector-shuffle-set! out-vec idxs vals) gold)))
    ))

(module+ test
  (run-tests dsp-insts-tests))

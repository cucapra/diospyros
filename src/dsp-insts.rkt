#lang rosette

(require "utils.rkt"
         "configuration.rkt"
         rackunit
         racket/trace
         rackunit/text-ui)

(provide vector-shuffle
         vector-shuffle-set!
         vector-multiply
         vector-add
         vector-minus
         vector-mac
         vector-s-divide
         vector-negate
         vector-cos
         vector-sin
         cosine
         sine)

;; Define set of instructions commonly found in DSP architectures.

;; VECTOR SHUFFLE: return (append inps)[idxs[i]].
(define (vector-shuffle inps idxs)
  (assert (list? idxs) "Expected list")
  (assert (list? inps) "Expected list")
  (define all-inp (apply append inps))
  (for/list ([idx idxs])
    (assert (< (unbox idx) (length all-inp))
            (format "VECTOR-SHUFFLE: idx ~a larger than elements in input vector ~a" (unbox idx) all-inp))
    (box (v-list-get all-inp (unbox idx)))))

;; VECTOR-SHUFFLE-SET!: store vals[i] into out-vec[idxs[i]]
(define (vector-shuffle-set! out-vec idxs vals)
  (assert (= (length idxs) (length vals))
          "VECTOR-SHUFFLE-SET: length mismatch")
  (assert (<= (length idxs) (length out-vec))
          "VECTOR-SHUFFLE-SET: idxs is larger than out-vec")
  (assert (apply distinct? idxs)
          "VECTOR-SHUFFLE-SET: duplicate indices")
  (for ([idx idxs]
        [val vals])
    (v-list-set! out-vec (unbox idx) (unbox val)))
  out-vec)

;; VECTOR MULTIPLY
(define (vector-multiply v1 v2)
  (assert (= (length v1) (length v2))
          "VECTOR-MULTIPLY: length of vectors not equal")
  (for/list ([e1 v1]
             [e2 v2])
    (box (* (unbox e1) (unbox e2)))))

;; VECTOR ADD
(define (vector-add v1 v2)
  (assert (= (length v1) (length v2))
          "VECTOR-ADD: length of vectors not equal")
  (for/list ([e1 v1]
             [e2 v2])
    (box (+ (unbox e1) (unbox e2)))))

;; VECTOR MINUS
(define (vector-minus v1 v2)
  (assert (= (length v1) (length v2))
          "VECTOR-MINUS: length of vectors not equal")
  (for/list ([e1 v1]
             [e2 v2])
    (box (- (unbox e1) (unbox e2)))))

;; VECTOR-MAC
(define (vector-mac v-acc v1 v2)
  (assert (= (length v1)
             (length v2)
             (length v-acc))
          "VECTOR-MAC: length of vectors not equal")
  (for/list ([e-acc v-acc]
             [e1 v1]
             [e2 v2])
    (box (+ (unbox e-acc) (* (unbox e1) (unbox e2))))))

; Define sine and cosine as an interpreted functions
(define-symbolic cosine (~> real? real?))
(define-symbolic sine (~> real? real?))

;; VECTOR SIGNED DIVIDE
(define (vector-s-divide v1 v2)
  (assert (= (length v1) (length v2))
          "VECTOR-S-DIVIDE: length of vectors not equal")
  (for/list ([e1 v1]
             [e2 v2])
    (box (/ (unbox e1) (unbox e2)))))

;; VECTOR-NEGATE
(define (vector-negate v)
  (for/list ([e v])
    (box (- (unbox e)))))

;; VECTOR-COSINE
(define (vector-cos v)
  (for/list ([e v])
    (box (cosine (unbox e)))))

;; VECTOR-SINE
(define (vector-sin v)
  (for/list ([e v])
    (box (sine (unbox e)))))

(define dsp-insts-tests
  (test-suite
    "DSP instructions tests"
    (test-case
      "VECTOR-SHUFFLE: basic example, one register"
      (let ([inp (v-list 0 1 2 3 4)]
            [idxs (v-list 1 1 0 3 4 2)]
            [gold (v-list 1 1 0 3 4 2)])
        (check-equal? (vector-shuffle (list inp) idxs) gold)))

    (test-case
      "VECTOR-SHUFFLE: synthesize indices"
      (define idxs-gold (v-list 6 2 4 3))
      (define-symbolic* idxs-lst real? [4])
      (define idxs (map box idxs-lst))
      (define inp (v-list 10 11 22 5 7 14 6))
      (define out-gold (v-list 6 22 7 5))
      (define idxs-synth
        (evaluate
          idxs
          (solve (assert (equal? (vector-shuffle (list inp) idxs) out-gold)))))
      (check-equal? idxs-synth idxs-gold))

    (test-case
      "VECTOR-SHUFFLE: basic example, multiple registers"
      (let ([inp1 (v-list 0 1 2 3)]
            [inp2 (v-list 10 11 12 13)]
            [idxs (v-list 7 7 0 3 2 5)]
            [gold (v-list 13 13 0 3 2 11)])
        (check-equal? (vector-shuffle (list inp1 inp2) idxs) gold)))

    (test-case
      "VECTOR-SHUFFLE-SET: basic example, one register"
      (let ([out-vec (v-list 0 0 0 0)]
            [vals (v-list 10 11 12 13)]
            [idxs (v-list 3 1 0 2)]
            [gold (v-list 12 11 13 10)])
        (check-equal? (vector-shuffle-set! out-vec idxs vals) gold)))
    ))

(module+ test
  (run-tests dsp-insts-tests))

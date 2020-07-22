#lang rosette

(require "utils.rkt"
         "configuration.rkt"
         rackunit
         racket/trace
         rackunit/text-ui)

(provide vector-shuffle
         vector-shuffle-set!
         vector-multiply
         vector-max
         vector-add
         vector-combine
         vector-reduce-sum
         vector-amount
         vector-average
         vector-sqr
         vector-sqrt
         vector-sub-average
         vector-standard-deviation
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
    (assert (bvslt (unbox idx)
                   (bitvectorize-concrete (index-fin)
                                          (length all-inp)))
            (format "VECTOR-SHUFFLE: idx ~a larger than elements in input vector ~a" (unbox idx) all-inp))
    (box (bv-list-get all-inp (unbox idx)))))

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
    (bv-list-set! out-vec (unbox idx) (unbox val)))
  out-vec)

;; VECTOR MULTIPLY
(define (vector-multiply v1 v2)
  (assert (= (length v1) (length v2))
          "VECTOR-MULTIPLY: length of vectors not equal")
  (for/list ([e1 v1]
             [e2 v2])
    (box (bvmul (unbox e1) (unbox e2)))))

;; VECTOR MAX

(define (vector-max v)
  (map max v))

;; VECTOR ADD
(define (vector-add v1 v2)
  (assert (= (length v1) (length v2))
          "VECTOR-ADD: length of vectors not equal")
  (for/list ([e1 v1]
             [e2 v2])
    (box (bvadd (unbox e1) (unbox e2)))))

;; VECTOR COMBINE
(define (vector-combine v1 v2)
  (append v1 v2))

;; VECTOR REDUCE SUM
(define (vector-reduce-sum v)
  (define (combine b acc) (bvadd acc (unbox b)))
  (list (box (foldl combine (bv-value 0) v))))

;;VECTOR AMOUNT
(define (vector-amount v) 
  (list (box (bv-value (length v)))))
  

;;VECTOR AVERAGE
(define (vector-average v s)
  (assert (= (length v) (length s))
          "VECTOR-AVERAGE: length of vectors not equal")
  (for/list ([n1 v]
             [n2 s])
    (box (bvsdiv (unbox n1) (unbox n2)))))

;; VECTOR SQUARED
(define (vector-sqr v)
  (bvmul v v))

;; VECTOR SUB AVERAGE
(define (vector-sub-average v a)
    (map bvsub v (unbox (first a))))

;; VECTOR SQUARE ROOT
(define (vector-sqrt s t)
  (define (sum s t)
      (if (equal? (for/list ([n1 s]
                             [n2 t]
                             #:when (equal? (bvmul n1 n1) (first t)))
    n1) '())
        (sum (map bvadd1 s) t)
        (map box s))) ;; (append (map box s) (make-bv-list-zeros 3))?
  (sum s t))

; infinite loop
;(define (vector-sqrt s t)
  ;(define (sum s t)
      ;(if (equal? (vector-sqr s) t)
         ; (list (box s))     
         ; (sum (bvadd1 s) t)))
  ;(sum s t))

;(map bitvector->integer (map unbox (vector-sqrt (bv-value 0) (bv-value 25))))

;;VECTOR STANDARD DEVIATION
(define (vector-standard-deviation v a h)
  (define (thing t u) (bvadd u t))
  (define (maybe p) (bvsub p (unbox (first a))))
  (vector-sqrt (list (bv-value 0)) (list (bvsdiv (foldl thing (bv-value 0)
                           (map vector-sqr (map maybe (map unbox v))))
             (bvsub (unbox (first h)) (bv-value 1))))))




;; VECTOR-MAC
(define (vector-mac v-acc v1 v2)
  (assert (= (length v1)
             (length v2)
             (length v-acc))
          "VECTOR-MAC: length of vectors not equal")
  (for/list ([e-acc v-acc]
             [e1 v1]
             [e2 v2])
    (box (bvadd (unbox e-acc) (bvmul (unbox e1) (unbox e2))))))

; Define sine and cosine as an interpreted functions
(define-symbolic cosine (~> (bitvector (value-fin))
                            (bitvector (value-fin))))
(define-symbolic sine (~> (bitvector (value-fin))
                          (bitvector (value-fin))))

;; VECTOR SIGNED DIVIDE
(define (vector-s-divide v1 v2)
  (assert (= (length v1) (length v2))
          "VECTOR-S-DIVIDE: length of vectors not equal")
  (for/list ([e1 v1]
             [e2 v2])
    (box (bvsdiv (unbox e1) (unbox e2)))))

;; VECTOR-NEGATE
(define (vector-negate v)
  (for ([e v])
    (set-box! e (bvneg (unbox e)))))

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
      "VECTOR-REDUCE_SUM: basic example"
      (let ([inp (value-bv-list 0 1 2 3 4)]
            [gold (value-bv-list 10)])
        (check-equal? (vector-reduce-sum inp) gold)))
    
;     (test-case
;      "VECTOR-AVERAGE: basic example"
;      (let ([inp (value-bv-list 1 2 3 6)]
;            [gold (value-bv-list 3)])
;        (check-equal? (vector-average inp 8) gold)))
     
    (test-case
      "VECTOR-SHUFFLE: basic example, one register"
      (let ([inp (value-bv-list 0 1 2 3 4)]
            [idxs (index-bv-list 1 1 0 3 4 2)]
            [gold (value-bv-list 1 1 0 3 4 2)])
        (check-equal? (vector-shuffle (list inp) idxs) gold)))

    (test-case
      "VECTOR-SHUFFLE: synthesize indices"
      (define idxs-gold (index-bv-list 6 2 4 3))
      (define-symbolic* idxs-lst (bitvector (index-fin)) [4])
      (define idxs (map box idxs-lst))
      (define inp (index-bv-list 10 11 22 5 7 14 6))
      (define out-gold (index-bv-list 6 22 7 5))
      (define idxs-synth
        (evaluate
          idxs
          (solve (assert (equal? (vector-shuffle (list inp) idxs) out-gold)))))
      (check-equal? idxs-synth idxs-gold))

    (test-case
      "VECTOR-SHUFFLE: basic example, multiple registers"
      (let ([inp1 (value-bv-list 0 1 2 3)]
            [inp2 (value-bv-list 10 11 12 13)]
            [idxs (index-bv-list 7 7 0 3 2 5)]
            [gold (value-bv-list 13 13 0 3 2 11)])
        (check-equal? (vector-shuffle (list inp1 inp2) idxs) gold)))

    (test-case
      "VECTOR-SHUFFLE-SET: basic example, one register"
      (let ([out-vec (value-bv-list 0 0 0 0)]
            [vals (value-bv-list 10 11 12 13)]
            [idxs (index-bv-list 3 1 0 2)]
            [gold (value-bv-list 12 11 13 10)])
        (check-equal? (vector-shuffle-set! out-vec idxs vals) gold)))
    ))

(module+ test
  (run-tests dsp-insts-tests))

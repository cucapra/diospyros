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
         vector-standard-deviation
         vector-mac
         vector-s-divide
         vector-negate
         vector-cos
         vector-sin
         bv-sqrt
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

(define (vector-max v1 v2 v3 v4 v5 v6)
  argmax v1 v2 v3 v4 v5 v6)
  
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
(define (vector-average v h)
  (assert (= (length v) (length h))
          "VECTOR-AVERAGE: length of vectors not equal")
  (for/list ([n1 v]
             [n2 h])
    (box (bvsdiv (unbox n1) (unbox n2)))))

;; VECTOR SQUARED
(define (vector-sqr v)
  (bvmul v v))

;; BITVECTOR SQUARE ROOT
(define (bv-sqrt t)
  (define (check-sqrt guess)
    (define guess-squared (bvmul guess guess))
    (cond
      [(bvsgt guess t)
       ; The squared number is now greater than our target, so there must not be one
       (error "No square root found")]
      [(bvsgt guess (bv-value (sqrt (expt 2 (value-fin)))))
       ; Case to ensure that the function terminates on symbolic values
       (error "No square root found")]
      [(equal? guess-squared t)
       ; Success! We found the square root
       guess]
      [else
       ; Recursive case, add 1 to the guess   
       (check-sqrt (bvadd1 guess))]))
  (check-sqrt (bv-value 0)))

;;VECTOR STANDARD DEVIATION
(define (vector-standard-deviation v a h)
  ; Subs the vectors by the average
  (define (sub-average v) (bvsub v (unbox (first a))))
  ; Adds the squared vectors
  (define (reduce-sum b acc) (bvadd acc b))
  ; Square roots
  (define sqrt
    (bv-sqrt (bvsdiv (foldl reduce-sum (bv-value 0)
                            (map vector-sqr (map sub-average (map unbox v))))
                     (bvsub (unbox (first h)) (bv-value 1)))))
  (append (list (box sqrt)) (make-bv-list-zeros 3)))


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

    (test-case
     "VECTOR-COMBINE basic examples"
       (define (check-vector-combine v1 v2)
         (map bitvector->integer (map unbox (vector-combine v1 v2))))
       (check-equal? (check-vector-combine (value-bv-list 1 2 3 4) (value-bv-list 5 6 7 8)) (list 1 2 3 4 5 6 7 8))
       (check-equal? (check-vector-combine (value-bv-list 17 26 39 47) (value-bv-list 54 68 79 80)) (list 17 26 39 47 54 68 79 80))
       (check-equal? (check-vector-combine (value-bv-list 0 8) (value-bv-list 9 10)) (list 0 8 9 10))
       (check-equal? (check-vector-combine (value-bv-list 8 9 0) (value-bv-list 67 90 14)) (list 8 9 0 67 90 14))
       (check-equal? (check-vector-combine (value-bv-list 1 2 3 4 5 6 7 8 9 10) (value-bv-list 11 12 13 14 15 16 17 18 19 20)) (list 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)))

    (test-case
      "VECTOR-AMOUNT: basic examples"
      (define (check-vector-amount v)
         (map bitvector->integer (map unbox (vector-amount v))))
       (check-equal? (check-vector-amount (value-bv-list 4 2 5 6)) (list 4))
       (check-equal? (check-vector-amount (value-bv-list 8 4)) (list 2))
       (check-equal? (check-vector-amount (value-bv-list 7 9 16 90 71)) (list 5))
       (check-equal? (check-vector-amount (value-bv-list 1 2 3 4 5 6 7 8 9 10)) (list 10))
       (check-equal? (check-vector-amount (value-bv-list 1)) (list 1)))

     (test-case
      "VECTOR-AVERAGE: basic examples"
      (define (check-bv-average v h)
         (map bitvector->integer (map unbox (vector-average v h))))
       (check-equal? (check-bv-average (value-bv-list 4 0 0 0) (value-bv-list 2 0 0 0)) (list 2 -1 -1 -1))
       (check-equal? (check-bv-average (value-bv-list 8 0 0 0) (value-bv-list 4 0 0 0)) (list 2 -1 -1 -1))
       (check-equal? (check-bv-average (value-bv-list 16 0 0 0) (value-bv-list 4 0 0 0)) (list 4 -1 -1 -1))
       (check-equal? (check-bv-average (value-bv-list 24 0 0 0) (value-bv-list 8 0 0 0)) (list 3 -1 -1 -1))
       (check-equal? (check-bv-average (value-bv-list 36 0 0 0) (value-bv-list 6 0 0 0)) (list 6 -1 -1 -1))
       (check-equal? (check-bv-average (value-bv-list 81 0 0 0) (value-bv-list 9 0 0 0)) (list 9 -1 -1 -1)))

     (test-case
      "VECTOR-SQR: basic examples"
      (define (check-vector-sqr v)
         (bitvector->integer (vector-sqr v)))
       (check-equal? (check-vector-sqr (bv-value 2)) 4)
       (check-equal? (check-vector-sqr (bv-value 4)) 16)
       (check-equal? (check-vector-sqr (bv-value 5)) 25)
       (check-equal? (check-vector-sqr (bv-value 10)) 100)
       (check-equal? (check-vector-sqr (bv-value 9)) 81))
     
     (test-case
     "BITVECTOR_SQRT basic examples"
       (define (check-bv-sqrt int-value)
         (bitvector->integer (bv-sqrt (bv-value int-value))))
       (check-equal? (check-bv-sqrt 0) 0)
       (check-equal? (check-bv-sqrt 4) 2)
       (check-equal? (check-bv-sqrt 9) 3)
       (check-equal? (check-bv-sqrt 16) 4)
       (check-equal? (check-bv-sqrt 25) 5)
       (check-equal? (check-bv-sqrt 36) 6)
       (check-equal? (check-bv-sqrt 81) 9))

     (test-case
      "VECTOR-STANDARD-DEVIATION: basic example"
      (define (check-vector-standard-deviation v a h)
         (map bitvector->integer (map unbox (vector-standard-deviation v a h))))
       (check-equal? (check-vector-standard-deviation (value-bv-list 1 2 3 6 1 2 3 6) (value-bv-list 3 -1 -1 -1) (value-bv-list 8 0 0 0)) (list 2 0 0 0)))

     
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

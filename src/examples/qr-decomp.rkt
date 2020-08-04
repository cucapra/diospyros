#lang rosette
(require "../utils.rkt"
         "../configuration.rkt"
         "matrix-multiply.rkt")

;(require math/matrix math/array)

(define (matrix-transpose m)
  (match-define (matrix rows cols elems) m)
  (define out (matrix cols rows (make-bv-list-zeros (* rows cols))))
  (for* ([i rows]
         [j cols])
    (matrix-set! out j i (matrix-ref m i j)))
  out)

(define (eq-as-float? i j)
  (if (equal? i j) 1.0 0.0))

; TODO: maybe replace uninterpreted function?
(define (sgn-as-float x)
  (pretty-print x)
  (cond
    [(bvslt x (bv-value 0)) -1.0]
    [(bvsgt x (bv-value 0)) 1.0]
    [else 0.0]))

(define-symbolic bv-sqrt (~> (bitvector (value-fin))
                          (bitvector (value-fin))))
(define-symbolic bv-sgn (~> (bitvector (value-fin))
                          (bitvector (value-fin))))

(define (vector-norm v
                     [sqrt-func bv-sqrt])
  (define (bv-sqr x) (bvmul (unbox x) (unbox x)))
  (sqrt-func (apply bvadd (map bv-sqr v))))

(define (q-i q-min i j k)
  (if (or (< i k) (< j k))
    (eq-as-float? i j)
    (matrix-ref q-min (- i k) (- j k))))

(define (identity n)
  (define I (matrix n n (make-bv-list-zeros (* n n))))
  (for* ([i (in-range n)]
         [j (in-range n)])
    (matrix-set! I i j (eq-as-float? i j)))
  I)

(define (househoulder A
                     [sgn-func bv-sgn])
  (match-define (matrix A-rows A-cols A-elements) A)
  (assert (equal? A-rows A-cols))
  (define n A-rows)

  ; Initialize R to be a copy of A's elements
  (define R (matrix n n (map box (map unbox A-elements))))

  ; Create Q as a zero matrix of the same size
  (define Q (matrix n n (make-bv-list-zeros (* n n))))

  ; Create identity of the same size
  (define I (identity n))

  (for ([k (in-range (sub1 n))])

    ; Create the vectors x, e and the scalar alpha
    (define x (make-bv-list-zeros (- n k)))
    (define e (make-bv-list-zeros (- n k)))
    (for ([row (in-range k n)]
          [i (in-naturals 0)])
     (bv-list-set! x (bv-index i) (matrix-ref R row k))
     (bv-list-set! e (bv-index i) (matrix-ref I row k)))

    (define alpha
      (bvmul (bvsub (sgn-func (bv-list-get x (bv-index 0))))
                    (vector-norm x)))
    0)

  (values R Q))


(define in (make-symbolic-matrix 3 3))
(pretty-print in)
(pretty-print (matrix-transpose in))

(define-values (Q R) (househoulder in))
(pretty-print Q)
(pretty-print R)

(pretty-print 'done)

#|
(define-values (T I col size)
  (values ; short names
   matrix-transpose identity-matrix matrix-col matrix-num-rows))

(define (scale c A) (matrix-scale A c))
(define (unit n i) (build-matrix n 1 (λ (j _) (if (= j i) 1 0))))

(define (H u)
  (matrix- (I (size u))
           (scale (/ 2 (matrix-dot u u))
                  (matrix* u (T u)))))

(define (normal a)
  (define a0 (matrix-ref a 0 0))
  (matrix- a (scale (* (sgn a0) (matrix-2norm a))
                    (unit (size a) 0))))

(define (QR A)
  (define n (size A))
  (for/fold ([Q (I n)] [R A]) ([i (- n 1)])
    (define Hi (H (normal (submatrix R (:: i n) (:: i (+ i 1))))))
    (define Hi* (if (= i 0) Hi (block-diagonal-matrix (list (I i) Hi))))
    (values (matrix* Q Hi*) (matrix* Hi* R))))
|#

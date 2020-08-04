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

(define (eq-as-value? i j)
  (if (equal? i j) (bv-value 1) (bv-value 0)))

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
    (eq-as-value? i j)
    (matrix-ref q-min (- i k) (- j k))))

(define (identity n)
  (define I (matrix n n (make-bv-list-zeros (* n n))))
  (for* ([i (in-range n)]
         [j (in-range n)])
    (matrix-set! I i j (eq-as-value? i j)))
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

    ; Create the vectors x, e (length dependent on n minus index, call this m)
    (define m (- n k))
    (define x (make-bv-list-zeros m))
    (define e (make-bv-list-zeros m))
    (for ([row (in-range k n)]
          [i (in-naturals 0)])
     (bv-list-set! x (bv-index i) (matrix-ref R row k))
     (bv-list-set! e (bv-index i) (matrix-ref I row k)))

    ; alpha is a scalar
    (define alpha
      (bvmul (bvsub (sgn-func (bv-list-get x (bv-index 0))))
                    (vector-norm x)))

    ; u and v length based on x and e
    (define u (make-bv-list-zeros m))
    (define v (make-bv-list-zeros m))

    ; Calculate u
    (for ([i (in-range m)])
      (define u-i (bvadd (bv-list-get x (bv-index i))
                         (bvmul alpha
                                (bv-list-get e (bv-index i)))))
      (bv-list-set! u (bv-index i) u-i))

    ; Calculate v
    (define norm-u (vector-norm u))
    (for ([i (in-range m)])
      (define v-i (bvsdiv (bv-list-get u (bv-index i))
                          norm-u))
      (bv-list-set! v (bv-index i) v-i))

    ; Create the Q minor matrix
    (define Q-min (matrix m m (make-bv-list-zeros (* m m))))
    (for* ([i (in-range m)]
           [j (in-range m)])
      (define q-min-i
        (bvsub (eq-as-value? i j)
               (bvmul (bv-value 2)
                      (bv-list-get v (bv-index i))
                      (bv-list-get v (bv-index j)))))
       (matrix-set! Q-min i j q-min-i))

    ; "Pad out" the Q minor matrix with elements from the identity
    (define Q-t (matrix n n (make-bv-list-zeros (* n n))))
    (for* ([i (in-range m)]
           [j (in-range m)])
       (matrix-set! Q-t i j (q-i Q-min i j k)))

    (if (equal? k 0)
      (begin
        (set-matrix-elements! Q
                              (matrix-elements Q-t))
        (set-matrix-elements! R
                              (matrix-multiply-spec Q-t A)))
      ; Else not first iteration
      (begin
        (set-matrix-elements! Q
                              (matrix-multiply-spec Q-t Q))
        (set-matrix-elements! R
                              (matrix-multiply-spec Q-t R)))))

  (values (matrix-transpose Q) R))


(define in (make-symbolic-matrix 3 3))
; (pretty-print in)
; (pretty-print (matrix-transpose in))

(define-values (Q R) (househoulder in))
(pretty-print Q)
(pretty-print R)

(pretty-print 'done)


#lang rosette

(struct matrix (rows cols elements) #:transparent #:mutable)

(define (list-set! l i v)
  (set-box! (list-ref l i) v))

(define (make-list-boxed n v)
  (map box (make-list n v)))

(define (list-ref-box l i)
  (unbox (list-ref l i)))

(define (matrix-ref mat row col)
  (match-define (matrix rows cols elements) mat)
  (assert (and (< row rows) (>= row 0)) (~a "MATRIX-REF: Invalid row " row))
  (assert (and (< col cols) (>= col 0)) (~a "MATRIX-REF: Invalid col " col))
  (list-ref-box elements (+ (* cols row) col)))

(define (matrix-set! mat row col val)
  (match-define (matrix rows cols elements) mat)
  (assert (and (< row rows) (>= row 0)) (~a "MATRIX-SET!: Invalid row " row))
  (assert (and (< col cols) (>= col 0)) (~a "MATRIX-SET!: Invalid col " col))
  (list-set! elements (+ (* cols row) col) val))

(define (matrix-multiply-spec mat-A mat-B)
  (match-define (matrix A-rows A-cols A-elements) mat-A)
  (match-define (matrix B-rows B-cols B-elements) mat-B)
  (assert (= A-cols B-rows))
  (define C
    (matrix A-rows
            B-cols
            (make-list-boxed (* A-rows B-cols) 0)))
  (for* ([i A-rows]
         [j B-cols])
    (define sum
      (apply
        +
        (for/list ([k A-cols])
          (* (matrix-ref mat-A i k)
             (matrix-ref mat-B k j)))))
    (matrix-set! C i j sum))

  (matrix-elements C))

(define (matrix-transpose m)
  (match-define (matrix rows cols elems) m)
  (define out (matrix cols rows (make-list-boxed (* rows cols) 0)))
  (for* ([i rows]
         [j cols])
    (matrix-set! out j i (matrix-ref m i j)))
  out)

(define (eq-as-value? i j)
  (if (equal? i j) 1.0 0.0))

(define-symbolic bv-sqrt (~> real?
                          real?))
(define-symbolic bv-sgn (~> real?
                          real?))
(define (sqrt-mock x)
 (sqrt  x))

(define (vector-norm v
                     ; [sqrt-func bv-sqrt])
                    [sqrt-func sqrt-mock])
  (define (bv-sqr x) (* (unbox x) (unbox x)))
  (sqrt-func (apply + (map bv-sqr v))))

(define (q-i q-min i j k)
  (if (or (< i k) (< j k))
    (eq-as-value? i j)
    (matrix-ref q-min (- i k) (- j k))))

(define (identity n)
  (define I (matrix n n (make-list-boxed (* n n) 0)))
  (for* ([i (in-range n)]
         [j (in-range n)])
    (matrix-set! I i j (eq-as-value? i j)))
  I)

(define (sgn-mock x)
  (cond
    [(< x 0) -1]
    [(> x 0) 1]
    [else 0]))

(define (househoulder A
                     ; [sgn-func bv-sgn])
                     [sgn-func sgn-mock])
  (match-define (matrix A-rows A-cols A-elements) A)
  (assert (equal? A-rows A-cols))
  (define n A-rows)

  ; Initialize R to be a copy of A's elements
  (define R (matrix n n (map box (map unbox A-elements))))

  ; Create Q as a zero matrix of the same size
  (define Q (matrix n n (make-list-boxed (* n n) 0)))

  ; Create identity of the same size
  (define I (identity n))

  (for ([k (in-range (sub1 n))])

    ; Create the vectors x, e (length dependent on n minus index, call this m)
    (define m (- n k))
    (define x (make-list-boxed m 0))
    (define e (make-list-boxed m 0))
    (for ([row (in-range k n)]
          [i (in-naturals 0)])
     (list-set! x i (matrix-ref R row k))
     (list-set! e i (matrix-ref I row k)))

    (pretty-print "x")
    (pretty-print x)

    (pretty-print "e")
    (pretty-print e)

    (pretty-print "norm x")
    (pretty-print (vector-norm x))

    (pretty-print (sgn-func (list-ref-box x 0)))

    ; alpha is a scalar
    (define alpha
      (* (- (sgn-func (list-ref-box x 0)))
                    (vector-norm x)))

    (pretty-print "alpha")
    (pretty-print alpha)

    ; u and v length based on x and e
    (define u (make-list-boxed m 0))
    (define v (make-list-boxed m 0))

    ; Calculate u
    (for ([i (in-range m)])
      (define u-i (+ (list-ref-box x i)
                         (* alpha
                                (list-ref-box e i))))
      (list-set! u i u-i))

    ; Calculate v
    (define norm-u (vector-norm u))
    (for ([i (in-range m)])
      (define v-i (/ (list-ref-box u i)
                          norm-u))
      (list-set! v i v-i))

    (pretty-print "norm-u")
    (pretty-print norm-u)

    (pretty-print "v")
    (pretty-print v)

    ; Create the Q minor matrix
    (define Q-min (matrix m m (make-list-boxed (* m m) 0)))
    (for* ([i (in-range m)]
           [j (in-range m)])
      (define q-min-i
        (- (eq-as-value? i j)
               (* 2
                      (list-ref-box v i)
                      (list-ref-box v j))))
       (matrix-set! Q-min i j q-min-i))

    (pretty-print "Q-min")
    (pretty-print Q-min)

    ; "Pad out" the Q minor matrix with elements from the identity
    (define Q-t (matrix n n (make-list-boxed (* n n) 0)))
    (for* ([i (in-range n)]
           [j (in-range n)])
       (matrix-set! Q-t i j (q-i Q-min i j k)))

    (pretty-print "Q-t")
    (pretty-print Q-t)

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


;(define in (make-symbolic-matrix 3 3))
; [[12, -51, 4], [6, 167, -68], [-4, 24, -41]]
(define in (matrix 3
                   3
                   (map box (list 12 -51 4 6 167 -68 -4 24 -41))))
; (pretty-print in)
; (pretty-print (matrix-transpose in))

(define-values (Q R) (househoulder in))
(pretty-print (map unbox (matrix-elements Q)))
(pretty-print (map unbox (matrix-elements R)))

; (pretty-print 'done)


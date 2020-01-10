#lang rosette

(provide (all-defined-out))

;; Matrix implementation and helper methods.
(struct matrix (rows cols elements) #:transparent)

(define (matrix-ref mat row col)
  (match-define (matrix rows cols elements) mat)
  (assert (< row rows))
  (assert (< col cols))
  (vector-ref elements (+ (* cols row) col)))

(define (matrix-set! mat row col val)
  (match-define (matrix rows cols elements) mat)
  (assert (< row rows))
  (assert (< col cols))
  (vector-set! elements (+ (* cols row) col) val))

(define (make-symbolic-vector size)
  (for/vector ([sym (in-range size)])
    (define-symbolic* v integer?)
    v))

; Ensure that indices only access reg-count or fewer registers.
(define (make-symbolic-indices-restriced size reg-count)
  (define vec (make-symbolic-vector size))
  (define registers (map (lambda (sym) (floor (/ sym size)))
                         (vector->list vec)))
  (define registers-used (length (remove-duplicates registers)))
  (assert (<= registers-used reg-count))
  vec)

(define (make-symbolic-matrix rows cols)
  (matrix rows cols (make-symbolic-vector (* rows cols))))


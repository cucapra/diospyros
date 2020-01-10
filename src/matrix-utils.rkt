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
  (for/vector ([_ (in-range size)])
    (define-symbolic* v integer?)
    v))
; Ensure that indices only access reg-count or fewer registers.
(define (make-symbolic-indices-restriced size reg-limit reg-upper-bound)
  (define vec (make-symbolic-vector size))

  ; Check how many distinct registers these indices fall within.
  (define reg-used (make-vector reg-upper-bound #f))
  (for ([i (in-range size)])
    (define reg (quotient (vector-ref vec i) size))
    (vector-set! reg-used reg #t))

  (define registers-used (count identity (vector->list reg-used)))
  (assert (<= registers-used reg-limit))
  vec)

(define (make-symbolic-matrix rows cols)
  (matrix rows cols (make-symbolic-vector (* rows cols))))


#lang rosette

(provide (all-defined-out))

;; Matrix implementation and helper methods.
(struct matrix (rows cols elements) #:transparent)

(define (matrix-ref mat row col)
  (match-define (matrix rows cols elements) mat)
  (vector-ref elements (+ (* cols row) col)))

(define (matrix-set! mat row col val)
  (match-define (matrix rows cols elements) mat)
  (vector-set! elements (+ (* cols row) col) val))

(define (make-symbolic-vector size)
  (for/vector ([sym (in-range size)])
    (define-symbolic* v integer?)
    v))

(define (make-symbolic-matrix rows cols)
  (matrix rows cols (make-symbolic-vector (* rows cols))))


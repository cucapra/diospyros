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

;; Returns number of vectors accessed by an index vector assuming each vector
;; contains reg-size elements.
(define (reg-used idx-vec reg-size [upper-bound #f])
  ; Check how many distinct registers these indices fall within.
  (define reg-used (make-vector (or upper-bound reg-size) #f))
  (for ([idx idx-vec])
    (define reg (quotient idx reg-size))
    (vector-set! reg-used reg #t))
  (count identity (vector->list reg-used)))

(define (make-symbolic-indices-restriced size reg-limit reg-upper-bound)
  (define vec (make-symbolic-vector size))
  (assert (<= (reg-used vec size) reg-limit))
  vec)

(define (make-symbolic-matrix rows cols)
  (matrix rows cols (make-symbolic-vector (* rows cols))))

(module+ test
  (require rackunit
           rackunit/text-ui)
  (run-tests
    (test-suite
      "matrix utilities"
      (test-case
        "REG-USED: calculates correctly"
        (let ([idx-vec (vector 0 7 2 5 6 1)]
              [reg-size 2])
          (check-equal? 4 (reg-used idx-vec reg-size)))))))

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

; Returns 0-indexed register that this index resides in based on the
; current register size.
(define (reg-of reg-size idx)
  (quotient idx reg-size))

; Returns number of vectors accessed by an index vector assuming each vector
; contains reg-size elements.
(define (reg-used idx-vec reg-size upper-bound)
  ; Check how many distinct registers these indices fall within.
  (define reg-used (make-vector upper-bound #f))
  (for ([idx idx-vec])
    (vector-set! reg-used (reg-of reg-size idx) #t))
  (count identity (vector->list reg-used)))

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
          (check-equal? 4 (reg-used idx-vec reg-size 4)))))))

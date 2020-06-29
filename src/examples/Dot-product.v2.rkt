#lang rosette

(require test-engine/racket-tests)
(require threading)
(require "../utils.rkt")
(require "../ast.rkt")

;A val is a structure
;(make-val list-of-boxes list-of-boxes)
;interpretation two boxed bitvector lists

(define-struct val[vec1 vec2])

;Calculates the sum of the bitvectors

(define (action bv)
  (cond
    [(empty? (rest bv)) (first bv)]
    [else (bvadd (first bv) (action (rest bv)))]))

;Calculates the Dot product of two boxed bitvector lists
  
(define (dot-product p)
  (action
   (map bvmul
        (map unbox (val-vec1 p)) (map unbox (val-vec2 p)))))
                 
;Tests

(check-expect (dot-product (make-val (value-bv-list 0)
                                     (value-bv-list 0))) (bv #x00 8))

(check-expect (dot-product (make-val (value-bv-list 1 2)
                                     (value-bv-list 1 2))) (bv #x05 8))

(check-expect (dot-product (make-val (value-bv-list 1 2)
                                     (value-bv-list 3 4))) (bv #x0b 8))

(check-expect (dot-product (make-val (value-bv-list 1 2)
                                     (value-bv-list 3 4))) (bv #x0e 8))

(check-expect (dot-product (make-val (value-bv-list 0 1 2 3 4 5)
                                     (value-bv-list 0 1 2 3 4 5))) (bv #x37 8))

(check-expect (dot-product (make-val (value-bv-list 0 1 2 3 4 5)
                                     (value-bv-list 6 7 8 9 10 11))) (bv #x91 8))
                                                           


#lang rosette

(require "../ast.rkt"
         "../configuration.rkt"
         "../utils.rkt"
         "matrix-multiply.rkt")

(define (cross-product lhs rhs)
  (assert (= (matrix-rows lhs) (matrix-rows rhs) 3))
  (assert (= (matrix-cols lhs) (matrix-cols rhs) 1))

  (matrix
   3
   1
   (list
    (box (bvsub (bvmul (matrix-ref lhs 1 0) (matrix-ref rhs 2 0))
                (bvmul (matrix-ref lhs 2 0) (matrix-ref rhs 1 0))))
    (box (bvsub (bvmul (matrix-ref lhs 2 0) (matrix-ref rhs 0 0))
                (bvmul (matrix-ref lhs 0 0) (matrix-ref rhs 2 0))))
    (box (bvsub (bvmul (matrix-ref lhs 0 0) (matrix-ref rhs 1 0))
                (bvmul (matrix-ref lhs 1 0) (matrix-ref rhs 0 0)))))))

(define (point-product q p)
  (assert (= (matrix-rows q) 4))
  (assert (= (matrix-rows p) 3))
  (assert (= (matrix-cols q) (matrix-cols p) 1))

  (define qvec (matrix 3 1 (take (matrix-elements q) 3)))

  (define uv (cross-product qvec p))
  (for ([i 3])
    (matrix-set! uv i 0 (bvmul (bv-value 2) (matrix-ref uv i 0))))

  (define qxuv (cross-product qvec uv))

  (define result (matrix 3 1 (make-bv-list-zeros 3)))
  (for ([i 3])
    (matrix-set! result i 0 (bvadd (matrix-ref p i 0)
                                   (bvmul (matrix-ref q 3 0) (matrix-ref uv i 0))
                                   (matrix-ref qxuv i 0))))

  result)

(define (quaternion-product a-q a-t b-q b-t)
  (assert (= (matrix-rows a-q) (matrix-rows b-q) 4))
  (assert (= (matrix-rows a-t) (matrix-rows b-t) 3))
  (assert (= (matrix-cols a-q) (matrix-cols b-q) (matrix-cols a-t) (matrix-cols b-t) 1))

  (define r-q
    (matrix
     4
     1
     (list
      (box (bvsub
            (bvadd (bvmul (matrix-ref a-q 3 0) (matrix-ref b-q 0 0))
                   (bvmul (matrix-ref a-q 0 0) (matrix-ref b-q 3 0))
                   (bvmul (matrix-ref a-q 1 0) (matrix-ref b-q 2 0)))
            (bvmul (matrix-ref a-q 2 0) (matrix-ref b-q 1 0))))
      (box (bvsub
            (bvadd (bvmul (matrix-ref a-q 3 0) (matrix-ref b-q 1 0))
                   (bvmul (matrix-ref a-q 1 0) (matrix-ref b-q 3 0))
                   (bvmul (matrix-ref a-q 2 0) (matrix-ref b-q 0 0)))
            (bvmul (matrix-ref a-q 0 0) (matrix-ref b-q 2 0))))
      (box (bvsub
            (bvadd (bvmul (matrix-ref a-q 3 0) (matrix-ref b-q 2 0))
                   (bvmul (matrix-ref a-q 2 0) (matrix-ref b-q 3 0))
                   (bvmul (matrix-ref a-q 0 0) (matrix-ref b-q 1 0)))
            (bvmul (matrix-ref a-q 1 0) (matrix-ref b-q 0 0))))
      (box (bvsub (bvmul (matrix-ref a-q 3 0) (matrix-ref b-q 3 0))
                  (bvmul (matrix-ref a-q 0 0) (matrix-ref b-q 0 0))
                  (bvmul (matrix-ref a-q 1 0) (matrix-ref b-q 1 0))
                  (bvmul (matrix-ref a-q 2 0) (matrix-ref b-q 2 0)))))))

  (define r (point-product a-q b-t))
  (define r-t
    (matrix
     3
     1
     (for/list ([i 3])
       (box (bvadd (matrix-ref a-t i 0) (matrix-ref r i 0))))))

  (values r-q r-t))

(module+ test
  (require rackunit)
  
  (define lhs (matrix 3 1 (value-bv-list 1 2 3)))
  (define rhs (matrix 3 1 (value-bv-list -1 4 6)))
  (define prod (cross-product lhs rhs))
  (check-equal? (matrix-elements prod)
                (value-bv-list 0 -9 6))

  ; pretend these are fixed point with a scaling factor 0.1
  (define a-q (matrix 4 1 (value-bv-list 1 7 6 4)))
  (define a-t (matrix 3 1 (value-bv-list -5 3 1)))
  (define b-q (matrix 4 1 (value-bv-list 8 3 2 7)))
  (define b-t (matrix 3 1 (value-bv-list 4 9 4)))

  ; product is fixed point with scaling factor 0.01
  (define-values (r-q r-t) (quaternion-product a-q a-t b-q b-t))
  (check-equal? (matrix-elements r-q)
                (value-bv-list 35 107 -3 -13))
  ; what about r-t?
  )
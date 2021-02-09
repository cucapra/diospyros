#lang rosette

(require "../ast.rkt"
         "../configuration.rkt"
         "../utils.rkt"
         "matrix-multiply.rkt")

(provide q-prod:only-spec
         q-prod:keys)

;; Runs the spec with symbolic inputs and returns:
;; - the resulting formula.
;; - the prelude instructions (list)
;; - outputs that the postlude should write to
(define (q-prod:only-spec config)
  (define aq (make-symbolic-matrix 4 1 'aq))
  (define at (make-symbolic-matrix 3 1 'at))
  (define bq (make-symbolic-matrix 4 1 'bq))
  (define bt (make-symbolic-matrix 3 1 'bt))


  (define prelude
    (list
      (vec-extern-decl 'aq (* 4 1) input-array-tag)
      (vec-extern-decl 'at (* 3 1) input-array-tag)
      (vec-extern-decl 'bq (* 4 1) input-array-tag)
      (vec-extern-decl 'bt (* 3 1) input-array-tag)
      (vec-extern-decl 'bt (* 3 1) input-array-tag)
      (vec-extern-decl 'rq (* 4 1) output-tag)
      (vec-extern-decl 'rt (* 4 1) output-tag)
      (vec-const 'Z (make-v-list-zeros 1) float-type)))

  (define-values (rq rt) (quaternion-product aq at bq bt))

  (define len-r-q (length (matrix-elements rq)))
  (define len-r-t (length (matrix-elements rt)))

  (define spec-r-q (align-to-reg-size (matrix-elements rq)))
  (define spec-r-t (align-to-reg-size (matrix-elements rt)))

  (values (append spec-r-q spec-r-t)
          (prog prelude)
          (list (list 'rq len-r-q)
                (list 'rt len-r-t))))

(define q-prod:keys
  (list 'reg-size))

(define (cross-product lhs rhs)
  (assert (= (matrix-rows lhs) (matrix-rows rhs) 3))
  (assert (= (matrix-cols lhs) (matrix-cols rhs) 1))

  (matrix
   3
   1
   (list
    (box (- (* (matrix-ref lhs 1 0) (matrix-ref rhs 2 0))
            (* (matrix-ref lhs 2 0) (matrix-ref rhs 1 0))))
    (box (- (* (matrix-ref lhs 2 0) (matrix-ref rhs 0 0))
            (* (matrix-ref lhs 0 0) (matrix-ref rhs 2 0))))
    (box (- (* (matrix-ref lhs 0 0) (matrix-ref rhs 1 0))
            (* (matrix-ref lhs 1 0) (matrix-ref rhs 0 0)))))))

(define (point-product q p)
  (assert (= (matrix-rows q) 4))
  (assert (= (matrix-rows p) 3))
  (assert (= (matrix-cols q) (matrix-cols p) 1))

  (define qvec (matrix 3 1 (take (matrix-elements q) 3)))

  (define uv (cross-product qvec p))
  (for ([i 3])
    (matrix-set! uv i 0 (* 2 (matrix-ref uv i 0))))

  (define qxuv (cross-product qvec uv))

  (define result (matrix 3 1 (make-v-list-zeros 3)))
  (for ([i 3])
    (matrix-set! result i 0 (+ (matrix-ref p i 0)
                                   (* (matrix-ref q 3 0) (matrix-ref uv i 0))
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
      (box (-
            (+ (* (matrix-ref a-q 3 0) (matrix-ref b-q 0 0))
               (* (matrix-ref a-q 0 0) (matrix-ref b-q 3 0))
               (* (matrix-ref a-q 1 0) (matrix-ref b-q 2 0)))
            (* (matrix-ref a-q 2 0) (matrix-ref b-q 1 0))))
      (box (-
            (+ (* (matrix-ref a-q 3 0) (matrix-ref b-q 1 0))
               (* (matrix-ref a-q 1 0) (matrix-ref b-q 3 0))
               (* (matrix-ref a-q 2 0) (matrix-ref b-q 0 0)))
            (* (matrix-ref a-q 0 0) (matrix-ref b-q 2 0))))
      (box (-
            (+ (* (matrix-ref a-q 3 0) (matrix-ref b-q 2 0))
               (* (matrix-ref a-q 2 0) (matrix-ref b-q 3 0))
               (* (matrix-ref a-q 0 0) (matrix-ref b-q 1 0)))
            (* (matrix-ref a-q 1 0) (matrix-ref b-q 0 0))))
      (box (- (* (matrix-ref a-q 3 0) (matrix-ref b-q 3 0))
              (* (matrix-ref a-q 0 0) (matrix-ref b-q 0 0))
              (* (matrix-ref a-q 1 0) (matrix-ref b-q 1 0))
              (* (matrix-ref a-q 2 0) (matrix-ref b-q 2 0)))))))

  (define r (point-product a-q b-t))
  (define r-t
    (matrix
     3
     1
     (for/list ([i 3])
       (box (+ (matrix-ref a-t i 0) (matrix-ref r i 0))))))

  (values r-q r-t))

(module+ test
  (require rackunit)

  (define lhs (matrix 3 1 (v-list 1 2 3)))
  (define rhs (matrix 3 1 (v-list -1 4 6)))
  (define prod (cross-product lhs rhs))
  (check-equal? (matrix-elements prod)
                (v-list 0 -9 6))

  ; pretend these are fixed point with a scaling factor 0.1
  (define a-q (matrix 4 1 (v-list 1 7 6 4)))
  (define a-t (matrix 3 1 (v-list -5 3 1)))
  (define b-q (matrix 4 1 (v-list 8 3 2 7)))
  (define b-t (matrix 3 1 (v-list 4 9 4)))

  ; product is fixed point with scaling factor 0.01
  (define-values (r-q r-t) (quaternion-product a-q a-t b-q b-t))
  (check-equal? (matrix-elements r-q)
                (v-list 35 107 -3 -13))
  ; what about r-t?
  )
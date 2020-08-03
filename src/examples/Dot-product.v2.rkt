#lang rosette

(require test-engine/racket-tests)
(require threading)
(require "../utils.rkt")
(require "../ast.rkt")
(require "../interp.rkt")
(require "../dsp-insts.rkt")

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

; Note: here is the example from Alexa on using the vector DSL
(define/prog p
  ('x = vec-const (value-bv-list 1 2 3 4) int-type)
  ('y = vec-const (value-bv-list 5 6 7 8) int-type)
  ('add-result = vec-app 'vec-add (list 'x 'y)))

(define env (make-hash))

(define function-map (hash 'vec-add vector-add))

(interp p env #:fn-map function-map)

(define add-results (hash-ref env 'add-result))

; This prints the results of the addition
(map bitvector->integer (map unbox add-results))

; Here is a version where x and y are arugments
(define/prog p2
  ('x = vec-extern-decl 4 int-type)
  ('y = vec-extern-decl 4 int-type)
  ('add-result = vec-app 'vec-add (list 'x 'y)))

(define env2 (make-hash))
(hash-set! env2 'x (value-bv-list 1 2 1 2))
(hash-set! env2 'y (value-bv-list 0 1 0 1))

(interp p2 env2 #:fn-map function-map)

(define add-results2 (hash-ref env2 'add-result))

(map bitvector->integer (map unbox add-results2))

; Task for Jacob: write dot product using the vector DSL



                                                           


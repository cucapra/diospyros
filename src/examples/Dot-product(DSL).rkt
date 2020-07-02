#lang rosette

(require test-engine/racket-tests)
(require threading)
(require "../utils.rkt")
(require "../ast.rkt")
(require "../interp.rkt")
(require "../dsp-insts.rkt")

; Task for Jacob: write dot product using the vector DSL

;Calculates the product of two boxed bitvector lists

(define/prog dot-product-p
  ('x = vec-extern-decl 4 int-type)
  ('y = vec-extern-decl 4 int-type)
  ('add-result = vec-app 'vec-mul (list 'x 'y)))

;Defines the bitvector lists 'x and 'y

(define action (make-hash))
(hash-set! action 'x (value-bv-list 0 1 2 3))
(hash-set! action 'y (value-bv-list 0 1 2 3))

;Maps the functions

(define function-map (hash 'vec-add vector-add
                           'vec-mul vector-multiply))

;Interpret the dot-product-p when action and function map are applied

(interp dot-product-p action #:fn-map function-map)

;Defines add-results as the value of the product of two boxed lists

(define add-results (hash-ref action 'add-result))

;Calculates the sum of the bitvectors turned into integers

(define (sum-of-integers p)
  (cond
    [(empty? (rest p)) (first p)]
    [else (+ (first p) (sum-of-integers (rest p)))]))

;Unboxes the add-results and turns the values into integers
;Sends Integers to sum-of-integers

(sum-of-integers (map bitvector->integer (map unbox add-results)))







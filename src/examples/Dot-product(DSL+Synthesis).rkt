#lang rosette

(require test-engine/racket-tests)
(require threading)
(require "../utils.rkt")
(require "../ast.rkt")
(require "../interp.rkt")
(require "../dsp-insts.rkt")
(require "../configuration.rkt")

; TODO: use synthesis!
; Given a certain list of results, use Rosette to find two input vector that
; have the resulting dot product.

; Hint: define symbolic bitvectors for the input
; (solve (equal? results (value-bv-list 0 1 2 3)))

;Calculates the product of two boxed bitvector lists

(define/prog dot-product-p
  ('x = vec-extern-decl 1 int-type)
  ('y = vec-extern-decl 1 int-type)
  ('mul-result = vec-app 'vec-mul (list 'x 'y))
  ('sum-result = vec-app 'vec-sum (list 'mul-result)))

;Defines the bitvector lists 'x and 'y

(define action (make-hash))
(hash-set! action 'x (make-symbolic-bv-list (bitvector (value-fin)) 1))
(hash-set! action 'y (make-symbolic-bv-list (bitvector (value-fin)) 1))

;Maps the functions

(define function-map (hash 'vec-add vector-add
                           'vec-mul vector-multiply
                           'vec-sum vector-reduce-sum))

;Interpret the dot-product-p when action and function-map are applied

(interp dot-product-p action #:fn-map function-map)

;Defines results as the value of the product of two boxed lists

(define results (hash-ref action 'sum-result))

;Defines model
;Solve so results = (value-bv-list 36 0 0 0)

(define model (solve (assert (equal? results (value-bv-list 36 0 0 0)))))

;Prints model

model

;Results->integer

(evaluate (map bitvector->integer (map unbox results)) model)


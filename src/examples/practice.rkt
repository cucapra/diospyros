#lang rosette

(require rosette/query/debug)
(require test-engine/racket-tests)
(require threading)
(require "../utils.rkt")
(require "../ast.rkt")
(require "../interp.rkt")
(require "../dsp-insts.rkt")
(require "../configuration.rkt")

;(define (always-same)
;  (define-symbolic x integer?)
;  x)

;(always-same)

;(define-symbolic x boolean?)

;(assert x)

;(asserts)

;(define-symbolic z y boolean?)
;(assert z)
;(asserts)

;(define sol (solve (assert y)))
;(asserts)
;(evaluate z sol)
;(evaluate y sol)
;(solve (assert (not z)))

;(define-symbolic x y integer?)
;(define inc (solve+))
;(inc (< x y))

;(inc (> x 5))

;(inc (< y 4))

;(define-symbolic x y boolean?)
;(assert x)
;(asserts)

;(define sol (verify (assert y)))
;(asserts)
;(evaluate x sol)
;(evaluate y sol)

;(define-symbolic x c integer?)
;(assert (even? x))
;(asserts)

;(define sol
;  (synthesize #:forall x
;              #:guarantee (assert (odd? (+ x c)))))

;(asserts)

;(evaluate x sol)

;(evaluate c sol)

;(define-symbolic x y integer?)

;(define (sum s t)
;  (* s t))

;(assert (= x y))

;(assert (sum x y))

;(define results (+ y x))

;(solve (assert (equal? results 36)))

(define-symbolic x y (bitvector (value-fin)))


(define/prog dot-product-p
  ('x = vec-extern-decl 1 int-type)
  ('y = vec-extern-decl 1 int-type)
  ('mul-result = vec-app 'vec-mul (list 'x 'y))
  ('sum-result = vec-app 'vec-sum (list 'mul-result)))

(define action (make-hash));
; (hash-set! action 'x (value-bv-list x 1 2 3))
(hash-set! action 'x (list (box x)))
(hash-set! action 'y (value-bv-list 2))


(define function-map (hash 'vec-add vector-add
                           'vec-mul vector-multiply
                           'vec-sum vector-reduce-sum))

(interp dot-product-p action #:fn-map function-map)

(define results (hash-ref action 'sum-result))

(box (map bitvector->integer (map unbox results)))

(define model (solve (assert (equal? results (value-bv-list 14 0 0 0)))))

model

(bitvector->integer (evaluate x model))









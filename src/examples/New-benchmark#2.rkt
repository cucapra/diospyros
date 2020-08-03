#lang rosette

(require "../ast.rkt"
         "../dsp-insts.rkt"
         "../interp.rkt"
         "../utils.rkt"
         "../prog-sketch.rkt"
         "../synth.rkt"
         "../configuration.rkt"
         racket/trace
         racket/generator
         rosette/lib/angelic)

;Checks if the bitvector list is sorted from largest tp smallest
;If not then the list is sorted

(define/prog sort-largest
  ('x = vec-extern-decl 2 int-type)
  ('vec-compare = vec-app 'vec-largest? (list 'x)))

(define action (make-hash))
(hash-set! action 'x (make-symbolic-bv-list (bitvector (value-fin)) 2))

;(define action (make-hash))
;(hash-set! action 'x (value-bv-list 1 2 3 4 10 12 15 12 18 20 14 16))

(define function-map (hash 'vec-largest? vector-sort-largest))

(interp sort-largest action #:fn-map function-map)

(define sorted (hash-ref action 'vec-compare))

(map bitvector->integer (map unbox sorted))

(define model (solve (assert (equal? sorted (value-bv-list 6 5)))))

model

(evaluate (map bitvector->integer (map unbox sorted)) model)





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

(define/prog bv-distance
  ('x = vec-extern-decl 2 int-type)
  ('y = vec-extern-decl 2 int-type)
  ('distance = vec-app 'vec-distance (list 'x 'y)))

(define action (make-hash))
(hash-set! action 'x (make-symbolic-bv-list (bitvector (value-fin)) 2))
(hash-set! action 'y (make-symbolic-bv-list (bitvector (value-fin)) 2))

;(define action (make-hash))
;(hash-set! action 'x (value-bv-list 4 6))
;(hash-set! action 'y (value-bv-list 1 2))

(define function-map (hash 'vec-distance vector-distance))

(interp bv-distance action #:fn-map function-map)

(define distance (hash-ref action 'distance))

(map bitvector->integer (map unbox distance))

(define model (solve (assert (equal? distance (value-bv-list 5 0 0 0)))))

model

(evaluate (map bitvector->integer (map unbox distance)) model)
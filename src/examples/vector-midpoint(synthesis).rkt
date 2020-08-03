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
  ('midpoint = vec-app 'vec-midpoint (list 'x 'y)))

(define action (make-hash))
(hash-set! action 'x (make-symbolic-bv-list (bitvector (value-fin)) 2))
(hash-set! action 'y (make-symbolic-bv-list (bitvector (value-fin)) 2))

;(define action (make-hash))
;(hash-set! action 'x (value-bv-list -3 3))
;(hash-set! action 'y (value-bv-list 5 3))

(define function-map (hash 'vec-midpoint vector-midpoint))

(interp bv-distance action #:fn-map function-map)

(define midpoint (hash-ref action 'midpoint))

(map bitvector->integer (map unbox midpoint))

(define model (solve (assert (equal? midpoint (value-bv-list 1 4 0 0)))))

model

(evaluate (map bitvector->integer (map unbox midpoint)) model)



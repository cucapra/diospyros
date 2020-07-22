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

; Run standard deviation with the given spec.
; Requires that spec be a hash with all the keys describes in standard-deviation:keys.

(define/prog desviacion-estandar-p
  ('x = vec-extern-decl 4 int-type)
  ('y = vec-extern-decl 4 int-type)
  ('combine-result = vec-app 'vec-combine (list 'x 'y))
  ('how-many = vec-app 'vec-amount? (list 'combine-result))
  ('sum-result = vec-app 'vec-sum (list 'combine-result))
  ('average = vec-app 'vec-average (list 'sum-result 'how-many))
  ('standard-deviation = vec-app 'vec-standard-deviation (list 'combine-result 'average 'how-many)))

;

(define action (make-hash))
(hash-set! action 'x (make-symbolic-bv-list (bitvector (value-fin)) 4))
(hash-set! action 'y (make-symbolic-bv-list (bitvector (value-fin)) 4))

;(define action (make-hash))
;(hash-set! action 'x (value-bv-list 1 2 3 6))
;(hash-set! action 'y (value-bv-list 1 2 3 6))

;

(define function-map (hash 'vec-combine vector-combine
                           'vec-sum vector-reduce-sum
                           'vec-amount? vector-amount
                           'vec-average vector-average
                           'vec-standard-deviation vector-standard-deviation))

;

(interp desviacion-estandar-p action #:fn-map function-map)

;

;(define combine-results (hash-ref action 'combine-result))
;(define how (hash-ref action 'how-many))
;(define sum-results (hash-ref action 'sum-result))
;(define average-results (hash-ref action 'average))
(define standard-deviation (hash-ref action 'standard-deviation))

;

(define model (solve (assert (equal? standard-deviation (value-bv-list 2 0 0 0)))))

model

;

;(map bitvector->integer (map unbox combine-results))
;(map bitvector->integer (map unbox how))
;(map bitvector->integer (map unbox average-results))
;(map bitvector->integer (map unbox standard-deviation))
;(evaluate (map bitvector->integer (map unbox combine-results)) model)
;(evaluate (map bitvector->integer (map unbox how)) model)
;(evaluate (map bitvector->integer (map unbox sum-results)) model)
;(evaluate (map bitvector->integer (map unbox average-results)) model)
(evaluate (map bitvector->integer (map unbox standard-deviation)) model)

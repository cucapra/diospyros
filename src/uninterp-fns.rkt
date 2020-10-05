#lang rosette

(require "configuration.rkt"
         "utils.rkt"
         "dsp-insts.rkt")

(provide (all-defined-out))

(define-symbolic v-sqrt (~> real? real?))
(define-symbolic v-sgn (~> real? real?))


(define (vector-sqrt v)
  (for/list ([e v])
    (box (v-sqrt (unbox e)))))

(define (vector-sgn v)
  (for/list ([e v])
    (box (v-sgn (unbox e)))))

(define uninterp-fn-map (make-hash))
(hash-set! uninterp-fn-map 'sqrt v-sqrt)
(hash-set! uninterp-fn-map 'sgn v-sgn)

; Predefined fns
(hash-set! uninterp-fn-map 'vec-mac vector-mac)
(hash-set! uninterp-fn-map 'vec-mul vector-multiply)
(hash-set! uninterp-fn-map 'vec-add vector-add)
(hash-set! uninterp-fn-map 'vec-div vector-s-divide)
(hash-set! uninterp-fn-map 'vec-neg vector-negate)
(hash-set! uninterp-fn-map 'vec-sqrt vector-sqrt)
(hash-set! uninterp-fn-map 'vec-sgn vector-sgn)
(hash-set! uninterp-fn-map 'neg bvsub)
(hash-set! uninterp-fn-map '* *)
(hash-set! uninterp-fn-map '+ +)
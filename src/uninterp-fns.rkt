#lang rosette

(require "configuration.rkt"
         "utils.rkt"
         "dsp-insts.rkt")

(provide (all-defined-out))

(define-symbolic sqrt (~> real? real?))
(define-symbolic sgn (~> real? real?))

(define (sgn-implementation v)
  (- (> v 0) (< v 0)))

(define (uninterp-fn-assumptions)
  (define-symbolic a real?)
  (list
    (equal? 1. (sqrt 1.))
    (forall (list a) (equal? (sgn a) (sgn-implementation a)))))

(define (vector-sqrt v)
  (for/list ([e v])
    (box (sqrt (unbox e)))))

(define (vector-sgn v)
  (for/list ([e v])
    (box (sgn (unbox e)))))

(define uninterp-fn-map (make-hash))
(hash-set! uninterp-fn-map 'sqrt sqrt)
(hash-set! uninterp-fn-map 'sgn sgn)

; Predefined fns
(hash-set! uninterp-fn-map 'vec-mac vector-mac)
(hash-set! uninterp-fn-map 'vec-mul vector-multiply)
(hash-set! uninterp-fn-map 'vec-add vector-add)
(hash-set! uninterp-fn-map 'vec-div vector-s-divide)
(hash-set! uninterp-fn-map 'vec-neg vector-negate)
(hash-set! uninterp-fn-map 'vec-sqrt vector-sqrt)
(hash-set! uninterp-fn-map 'vec-sgn vector-sgn)
(hash-set! uninterp-fn-map 'neg -)
(hash-set! uninterp-fn-map '* *)
(hash-set! uninterp-fn-map '/ /)
(hash-set! uninterp-fn-map '+ +)
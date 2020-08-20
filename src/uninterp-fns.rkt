#lang rosette

(require "configuration.rkt"
         "utils.rkt"
         "dsp-insts.rkt")

(provide (all-defined-out))

(define-symbolic bv-sqrt (~> (bitvector (value-fin))
                          (bitvector (value-fin))))
(define-symbolic bv-sgn (~> (bitvector (value-fin))
                          (bitvector (value-fin))))

(define uninterp-fn-map (make-hash))
(hash-set! uninterp-fn-map 'sqrt bv-sqrt)
(hash-set! uninterp-fn-map 'sgn bv-sgn)

; Predefined fns
(hash-set! uninterp-fn-map 'vec-mac vector-mac)
(hash-set! uninterp-fn-map 'vec-mul vector-multiply)
(hash-set! uninterp-fn-map 'vec-add vector-add)
(hash-set! uninterp-fn-map 'vec-neg vector-negate)
#lang rosette

(require "utils.rkt")


(define prog2
  '(define (naive_matrix_multiply a_in b_in c_out row1_size col1_size col2_size)
   (for
     ((y (in-range 0 row1_size 1)))
     ((for
       ((x (in-range 0 col2_size 1)))
       ((v-list-set! c_out (+ (* col2_size y) x) 0)
        (for
         ((k (in-range 0 col1_size 1)))
         ((v-list-set!
           c_out
           (+ (* col2_size y) x)
           (*
            (v-list-get a_in (+ (* col1_size y) k))
            (v-list-get b_in (+ (* col2_size k) x))))))))))))


(define (naive_matrix_multiply a_in b_in c_out row1_size col1_size col2_size)
   (begin (for
     ((y (in-range 0 row1_size 1)))
     (for
       ((x (in-range 0 col2_size 1)))
       (v-list-set! c_out (bv-index (+ (* col2_size y) x)) (bv-value 0))
        (for
         ((k (in-range 0 col1_size 1)))
         (v-list-set!
           c_out
           (bv-index (+ (* col2_size y) x))
           (bvmul
            (v-list-get a_in (bv-index (+ (* col1_size y) k)))
            (v-list-get b_in (bv-index (+ (* col2_size k) x))))))))))


(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))
;(eval prog2 ns)

;(eval `(naive_matrix_multiply (list (bv-value 1)) (list (bv-value 1)) (list (bv-value 1)) 1 1 1 ) ns)

(define c (value-bv-list 0))
(naive_matrix_multiply (value-bv-list 2) (value-bv-list 3) c 1 1 1)
(pretty-print c)


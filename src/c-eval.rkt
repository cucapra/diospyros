#lang rosette

(require "utils.rkt")


(define (matrix_multiply
          a_in
          b_in
          c_out
          a_rows_size
          a_cols_size
          b_rows_size
          b_cols_size)
   ((for
     ((y (in-range 0 a_rows_size 1)))
     ((for
       ((x (in-range 0 b_cols_size 1)))
       ((v-list-set! c_out (+ (* b_cols_size y) x) 0)
        (for
         ((k (in-range 0 a_cols_size 1)))
         ((v-list-set!
           c_out
           (+ (* b_cols_size y) x)
           (*
            (v-list-get a_in (+ (* a_cols_size y) k))
            (v-list-get b_in (+ (* b_cols_size k) x))))))))))))


(define-namespace-anchor anc)
(define ns (namespace-anchor->namespace anc))
;(eval prog2 ns)

;(eval `(naive_matrix_multiply (list (bv-value 1)) (list (bv-value 1)) (list (bv-value 1)) 1 1 1 ) ns)

(define c (v-list 0))
(matrix_multiply (v-list 4) (v-list 4) c 2 2 2 2)
(pretty-print c)


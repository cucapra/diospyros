'(define (matrix_multiply a_in b_in c_out)
   (begin
     (define test (make-v-list-zeros 9))
     (v-list-get test 4)
     (for
      ((y (in-range 0 2 1)))
      (begin
        (for
         ((x (in-range 0 2 1)))
         (begin
           (v-list-set! c_out (+ (* 2 y) x) 0)
           (for
            ((k (in-range 0 2 1)))
            (begin
              (v-list-set!
               c_out
               (+ (* 2 y) x)
               (+
                (v-list-get c_out (+ (* 2 y) x))
                (*
                 (v-list-get a_in (+ (* 2 y) k))
                 (v-list-get b_in (+ (* 2 k) x)))))))))))))
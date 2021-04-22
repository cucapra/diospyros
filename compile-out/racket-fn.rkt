'(begin
   (define (add_matrices a b c)
     (begin
       (for
        ((i (in-range 0 3 1)))
        (begin
          (for
           ((j (in-range 0 3 1)))
           (begin
             (v-list-set!
              c
              (+ j (* i 3))
              (+
               (v-list-get a (+ j (* i 3)))
               (v-list-get b (+ j (* i 3)))))))))))
   (define (multiply_matrices a_in b_in c_out)
     (begin
       (for
        ((i (in-range 0 3 1)))
        (begin
          (for
           ((j (in-range 0 3 1)))
           (begin
             (define sum 0.0)
             (for
              ((k (in-range 0 3 1)))
              (begin
                (set! sum
                  (+
                   sum
                   (*
                    (v-list-get a_in (+ k (* i 3)))
                    (v-list-get b_in (+ j (* k 3))))))))
             (v-list-set! c_out (+ j (* i 3)) sum)))))))
   (define (matrix_multiply a_in b_in c_out)
     (begin
       (define test4d (make-v-list-zeros 81))
       (v-list-get test4d (+ 2 (* (+ 2 (* (+ 2 (* 2 3)) 3)) 3)))
       (v-list-set! test4d (+ 0 (* (+ 1 (* (+ 0 (* 0 3)) 3)) 3)) 3.0)
       (v-list-set!
        test4d
        (+ 0 (* (+ 1 (* (+ 0 (* 0 3)) 3)) 3))
        (+
         (v-list-get test4d (+ 0 (* (+ 1 (* (+ 0 (* 0 3)) 3)) 3)))
         (v-list-get test4d (+ 0 (* (+ 1 (* (+ 0 (* 0 3)) 3)) 3)))))
       (define test (make-v-list-zeros 9))
       (v-list-set! test (+ 1 (* 1 3)) 3)
       (for
        ((y (in-range 0 3 1)))
        (begin
          (for
           ((x (in-range 0 3 1)))
           (begin (v-list-set! test (+ x (* y 3)) 1)))))
       (define extra (make-v-list-zeros 9))
       (for
        ((i (in-range 0 3 1)))
        (begin
          (for
           ((j (in-range 0 3 1)))
           (begin
             (define sum 0.0)
             (for
              ((k (in-range 0 3 1)))
              (begin
                (set! sum
                  (+
                   sum
                   (*
                    (v-list-get test (+ k (* i 3)))
                    (v-list-get test (+ j (* k 3))))))))
             (v-list-set! extra (+ j (* i 3)) sum)))))
       (for
        ((i (in-range 0 3 1)))
        (begin
          (for
           ((j (in-range 0 3 1)))
           (begin
             (v-list-set!
              extra
              (+ j (* i 3))
              (+
               (v-list-get extra (+ j (* i 3)))
               (v-list-get extra (+ j (* i 3)))))))))
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
                   (v-list-get b_in (+ (* 2 k) x))))))))))))))

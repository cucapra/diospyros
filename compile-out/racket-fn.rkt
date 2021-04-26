'(begin
   (define (sgn v) (begin (- (> v 0) (< v 0))))
   (define (naive_fixed_transpose a)
     (begin
       (for
        ((i (in-range 0 5 1)))
        (begin
          (for
           ((j (in-range (+ i 1) 5 1)))
           (begin
             (define tmp (v-list-get a (+ j (* i 5))))
             (v-list-set! a (+ j (* i 5)) (v-list-get a (+ i (* j 5))))
             (v-list-set! a (+ i (* j 5)) tmp)))))))
   (define (naive_norm x m)
     (begin
       (define sum 0)
       (for
        ((i (in-range 0 m 1)))
        (begin (set! sum (+ sum (pow (v-list-get x i) 2)))))
       (sqrt sum)))
   (define (naive_fixed_matrix_multiply a b c)
     (begin
       (for
        ((y (in-range 0 5 1)))
        (begin
          (for
           ((x (in-range 0 5 1)))
           (begin
             (v-list-set! c (+ x (* y 5)) 0)
             (for
              ((k (in-range 0 5 1)))
              (begin
                (v-list-set!
                 c
                 (+ x (* y 5))
                 (+
                  (v-list-get c (+ x (* y 5)))
                  (*
                   (v-list-get a (+ k (* y 5)))
                   (v-list-get b (+ x (* k 5))))))))))))))
   (define (naive_fixed_qr_decomp A Q R)
     (begin
       (for
        ((i (in-range 0 5 1)))
        (begin
          (for
           ((j (in-range 0 5 1)))
           (begin
             (v-list-set! R (+ j (* i 5)) (v-list-get A (+ j (* i 5))))))))
       (define I (make-v-list-zeros (* 5 5)))
       (for
        ((i (in-range 0 5 1)))
        (begin
          (for
           ((j (in-range 0 5 1)))
           (begin (v-list-set! I (+ j (* i 5)) (if (equal? i j) 1.0 0.0))))))
       (for
        ((k (in-range 0 (- 5 1) 1)))
        (begin
          (define m (- 5 k))
          (define x (make-v-list-zeros m))
          (define e (make-v-list-zeros m))
          (for
           ((i (in-range 0 m 1)))
           (begin
             (define row (+ k i))
             (v-list-set! x i (v-list-get R (+ k (* row 5))))
             (v-list-set! e i (v-list-get I (+ k (* row 5))))))
          (define alpha (* (- (sgn (v-list-get x 0))) (naive_norm x m)))
          (define u (make-v-list-zeros m))
          (define v (make-v-list-zeros m))
          (for
           ((i (in-range 0 m 1)))
           (begin
             (v-list-set!
              u
              i
              (+ (v-list-get x i) (* alpha (v-list-get e i))))))
          (define norm_u (naive_norm u m))
          (for
           ((i (in-range 0 m 1)))
           (begin (v-list-set! v i (/ (v-list-get u i) norm_u))))
          (define q_min (make-v-list-zeros (* m m)))
          (for
           ((i (in-range 0 m 1)))
           (begin
             (for
              ((j (in-range 0 m 1)))
              (begin
                (define q_min_i
                  (-
                   (if (equal? i j) 1.0 0.0)
                   (* (* 2 (v-list-get v i)) (v-list-get v j))))
                (v-list-set! q_min (+ j (* i m)) q_min_i)))))
          (define q_t (make-v-list-zeros (* 5 5)))
          (for
           ((i (in-range 0 5 1)))
           (begin
             (for
              ((j (in-range 0 5 1)))
              (begin
                (define q_t_i 0)
                (if (or (< i k) (< j k))
                  (begin (set! q_t_i (if (equal? i j) 1.0 0.0)))
                  (begin
                    (set! q_t_i (v-list-get q_min (+ (- j k) (* (- i k) m))))))
                (v-list-set! q_t (+ j (* i 5)) q_t_i)))))
          (if (equal? k 0)
            (begin
              (for
               ((i (in-range 0 5 1)))
               (begin
                 (for
                  ((j (in-range 0 5 1)))
                  (begin
                    (v-list-set!
                     Q
                     (+ j (* i 5))
                     (v-list-get q_t (+ j (* i 5))))))))
              (naive_fixed_matrix_multiply q_t A R))
            (begin
              (define res (make-v-list-zeros (* 5 5)))
              (naive_fixed_matrix_multiply q_t Q res)
              (for
               ((i (in-range 0 5 1)))
               (begin
                 (for
                  ((j (in-range 0 5 1)))
                  (begin
                    (v-list-set!
                     Q
                     (+ j (* i 5))
                     (v-list-get res (+ j (* i 5))))))))
              (naive_fixed_matrix_multiply q_t R res)
              (for
               ((i (in-range 0 5 1)))
               (begin
                 (for
                  ((j (in-range 0 5 1)))
                  (begin
                    (v-list-set!
                     R
                     (+ j (* i 5))
                     (v-list-get res (+ j (* i 5))))))))))))
       (naive_fixed_transpose Q)))
   (define (naive_cross_product lhs rhs result)
     (begin
       (v-list-set!
        result
        0
        (-
         (* (v-list-get lhs 1) (v-list-get rhs 2))
         (* (v-list-get lhs 2) (v-list-get rhs 1))))
       (v-list-set!
        result
        1
        (-
         (* (v-list-get lhs 2) (v-list-get rhs 0))
         (* (v-list-get lhs 0) (v-list-get rhs 2))))
       (v-list-set!
        result
        2
        (-
         (* (v-list-get lhs 0) (v-list-get rhs 1))
         (* (v-list-get lhs 1) (v-list-get rhs 0))))))
   (define (naive_dot_product a_in b_in c_out)
     (begin
       (for
        ((i (in-range 0 4 1)))
        (begin
          (set! c_out
            (+ c_out (* (v-list-get a_in i) (v-list-get b_in i))))))))
   (define (quaternion_matrix_vec_mult a_in b_in c_out)
     (begin
       (for
        ((i (in-range 0 4 1)))
        (begin
          (define sum 0.0)
          (for
           ((k (in-range 0 4 1)))
           (begin
             (set! sum
               (+
                sum
                (* (v-list-get a_in (+ k (* i 4))) (v-list-get b_in k))))))
          (v-list-set! c_out i sum)))))
   (define (naive_quaternion_product a_in b_in c_out)
     (begin
       (define A_matrix (make-v-list-zeros (* 4 4)))
       (v-list-set! A_matrix (+ 0 (* 0 4)) (v-list-get a_in 0))
       (v-list-set! A_matrix (+ 1 (* 0 4)) (v-list-get a_in 1))
       (v-list-set! A_matrix (+ 2 (* 0 4)) (v-list-get a_in 2))
       (v-list-set! A_matrix (+ 3 (* 0 4)) (v-list-get a_in 3))
       (v-list-set! A_matrix (+ 0 (* 1 4)) (- (v-list-get a_in 1)))
       (v-list-set! A_matrix (+ 1 (* 1 4)) (v-list-get a_in 0))
       (v-list-set! A_matrix (+ 2 (* 1 4)) (v-list-get a_in 3))
       (v-list-set! A_matrix (+ 3 (* 1 4)) (- (v-list-get a_in 2)))
       (v-list-set! A_matrix (+ 0 (* 2 4)) (- (v-list-get a_in 2)))
       (v-list-set! A_matrix (+ 1 (* 2 4)) (- (v-list-get a_in 3)))
       (v-list-set! A_matrix (+ 2 (* 2 4)) (v-list-get a_in 0))
       (v-list-set! A_matrix (+ 3 (* 2 4)) (v-list-get a_in 1))
       (v-list-set! A_matrix (+ 0 (* 3 4)) (- (v-list-get a_in 3)))
       (v-list-set! A_matrix (+ 1 (* 3 4)) (v-list-get a_in 2))
       (v-list-set! A_matrix (+ 2 (* 3 4)) (- (v-list-get a_in 1)))
       (v-list-set! A_matrix (+ 3 (* 3 4)) (v-list-get a_in 0))
       (quaternion_matrix_vec_mult A_matrix b_in c_out)))
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
       (define test4d (make-v-list-zeros (* 3 (* 3 (* 3 3)))))
       (v-list-get test4d (+ 2 (* (+ 2 (* (+ 2 (* 2 3)) 3)) 3)))
       (v-list-set! test4d (+ 0 (* (+ 1 (* (+ 0 (* 0 3)) 3)) 3)) 3.0)
       (v-list-set!
        test4d
        (+ 0 (* (+ 1 (* (+ 0 (* 0 3)) 3)) 3))
        (+
         (v-list-get test4d (+ 0 (* (+ 1 (* (+ 0 (* 0 3)) 3)) 3)))
         (v-list-get test4d (+ 0 (* (+ 1 (* (+ 0 (* 0 3)) 3)) 3)))))
       (define test (make-v-list-zeros (* 3 3)))
       (v-list-set! test (+ 1 (* 1 3)) 3)
       (for
        ((y (in-range 0 3 1)))
        (begin
          (for
           ((x (in-range 0 3 1)))
           (begin (v-list-set! test (+ x (* y 3)) 1)))))
       (define extra (make-v-list-zeros (* 3 3)))
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

'(begin
   (define (cross_product lhs rhs result)
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
   (define (point_product q_in p_in result_out)
     (begin
       (define qvec (make-v-list-zeros 3))
       (v-list-set! qvec 0 (v-list-get q_in 0))
       (v-list-set! qvec 1 (v-list-get q_in 1))
       (v-list-set! qvec 2 (v-list-get q_in 2))
       (define uv (make-v-list-zeros 3))
       (cross_product qvec p_in uv)
       (for
        ((i (in-range 0 3 1)))
        (begin (v-list-set! uv i (* (v-list-get uv i) 2))))
       (define qxuv (make-v-list-zeros 3))
       (cross_product qvec uv qxuv)
       (for
        ((i (in-range 0 3 1)))
        (begin
          (v-list-set!
           result_out
           i
           (+
            (+ (v-list-get p_in i) (* (v-list-get q_in 3) (v-list-get uv i)))
            (v-list-get qxuv i))))))))

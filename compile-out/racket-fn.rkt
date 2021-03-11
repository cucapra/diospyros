'(define (tern a_in b_out)
   (begin
     (for
      ((i (in-range 0 8 1)))
      (begin (v-list-set! b_out i (if (< i (/ 8 2)) (v-list-get a_in i) 0))))))

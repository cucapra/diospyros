(prog
 (list
  (vec-const 'Z '#(0) 'float)
  (vec-extern-decl 'q_in 4 'extern-input-array)
  (vec-extern-decl 'p_in 4 'extern-input-array)
  (vec-extern-decl 'result_out 4 'extern-output)))

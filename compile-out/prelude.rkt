(prog
 (list
  (vec-const 'Z '#(0.0) 'float)
  (vec-extern-decl 'a_in 4 'extern-input-array)
  (vec-extern-decl 'b_in 4 'extern-input-array)
  (vec-extern-decl 'c_out 4 'extern-output)))

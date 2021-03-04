(VecAdd
  (VecAdd
    (VecMul
      (Vec (Get q_in 1) (Get q_in 2) (Get q_in 0) 1)
      (VecMul
        (Vec 2 2 2 1)
        (VecAdd
          (VecMul
            (Vec (Get q_in 0) (Get q_in 1) (Get q_in 2) 1)
            (LitVec (Get p_in 1) (Get p_in 2) (Get p_in 0) 0))
          (VecNeg
            (VecMul
              (Vec (Get q_in 1) (Get q_in 2) (Get q_in 0) 1)
              (LitVec (Get p_in 0) (Get p_in 1) (Get p_in 2) 0))))))
    (VecNeg
      (VecMul
        (Vec (Get q_in 2) (Get q_in 0) (Get q_in 1) 1)
        (VecMul
          (Vec 2 2 2 1)
          (VecAdd
            (VecMul
              (Vec (Get q_in 2) (Get q_in 0) (Get q_in 1) 1)
              (LitVec (Get p_in 0) (Get p_in 1) (Get p_in 2) 0))
            (VecNeg
              (VecMul
                (Vec (Get q_in 0) (Get q_in 1) (Get q_in 2) 1)
                (LitVec (Get p_in 2) (Get p_in 0) (Get p_in 1) 0))))))))
  (VecMAC
    (LitVec (Get p_in 0) (Get p_in 1) (Get p_in 2) 0)
    (Vec (Get q_in 3) (Get q_in 3) (Get q_in 3) 1)
    (VecMul
      (Vec 2 2 2 1)
      (VecAdd
        (VecMul
          (Vec (Get q_in 1) (Get q_in 2) (Get q_in 0) 1)
          (LitVec (Get p_in 2) (Get p_in 0) (Get p_in 1) 0))
        (VecNeg
          (VecMul
            (Vec (Get q_in 2) (Get q_in 0) (Get q_in 1) 1)
            (LitVec (Get p_in 1) (Get p_in 2) (Get p_in 0) 0)))))))

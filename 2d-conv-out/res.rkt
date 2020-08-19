(Concat
  (VecMAC
    (VecMul
      (Vec4 1 (Get I 0) (Get I 1) 1)
      (LitVec4 0 (Get F 1) (Get F 1) 0))
    (LitVec4
      (Get I 0)
      (Get I 1)
      (Get I 2)
      (Get I 2))
    (LitVec4
      (Get F 0)
      (Get F 0)
      (Get F 0)
      (Get F 1)))
  (Concat
    (VecMAC
      (VecAdd
        (VecMul
          (Vec4 1 (Get I 1) (Get I 2) 1)
          (LitVec4 0 (Get F 2) (Get F 2) 0))
        (VecMAC
          (VecMul
            (Vec4 1 (Get I 3) (Get I 4) 1)
            (LitVec4 0 (Get F 1) (Get F 1) 0))
          (LitVec4
            (Get I 0)
            (Get I 4)
            (Get I 5)
            (Get I 2))
          (LitVec4
            (Get F 2)
            (Get F 0)
            (Get F 0)
            (Get F 3))))
      (LitVec4
        (Get I 3)
        (Get I 0)
        (Get I 1)
        (Get I 5))
      (LitVec4
        (Get F 0)
        (Get F 3)
        (Get F 3)
        (Get F 1)))
    (Concat
      (VecMAC
        (VecAdd
          (VecMul
            (Vec4 1 (Get I 4) (Get I 5) 1)
            (LitVec4 0 (Get F 2) (Get F 2) 0))
          (VecMAC
            (VecMul
              (Vec4 1 (Get I 6) (Get I 7) 1)
              (LitVec4 0 (Get F 1) (Get F 1) 0))
            (LitVec4
              (Get I 3)
              (Get I 7)
              (Get I 8)
              (Get I 5))
            (LitVec4
              (Get F 2)
              (Get F 0)
              (Get F 0)
              (Get F 3))))
        (LitVec4
          (Get I 6)
          (Get I 3)
          (Get I 4)
          (Get I 8))
        (LitVec4
          (Get F 0)
          (Get F 3)
          (Get F 3)
          (Get F 1)))
      (VecMAC
        (VecMul
          (Vec4 1 (Get I 6) (Get I 7) 1)
          (LitVec4 0 (Get F 3) (Get F 3) 0))
        (LitVec4
          (Get I 6)
          (Get I 7)
          (Get I 8)
          (Get I 8))
        (LitVec4
          (Get F 2)
          (Get F 2)
          (Get F 2)
          (Get F 3))))))

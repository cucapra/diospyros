(Concat
  (VecMAC
    (VecMAC
      (VecMul
        (LitVec4 0 0 (Get F 1) 0)
        (LitVec4 0 0 (Get I 1) 0))
      (LitVec4
        0
        (Get I 0)
        (Get I 2)
        (Get I 1))
      (LitVec4
        0
        (Get F 1)
        (Get F 0)
        (Get F 2)))
    (LitVec4
      (Get I 0)
      (Get I 1)
      (Get I 0)
      (Get I 2))
    (LitVec4
      (Get F 0)
      (Get F 0)
      (Get F 2)
      (Get F 1)))
  (Concat
    (VecMAC
      (VecMAC
        (VecMAC
          (Vec4
            0
            0
            (* (Get F 0) (Get I 4))
            (+
              (* (Get F 2) (Get I 3))
              (+
                (* (Get F 1) (Get I 4))
                (* (Get F 0) (Get I 5)))))
          (LitVec4 0 0 (Get I 3) (Get I 1))
          (Vec4 0 0 (Get F 1) (Get F 4)))
        (LitVec4
          0
          (Get I 0)
          (Get I 1)
          (Get I 2))
        (LitVec4
          0
          (Get F 3)
          (Get F 3)
          (Get F 3)))
      (LitVec4
        (Get F 2)
        (Get F 0)
        (Get F 4)
        (Get F 5))
      (LitVec4
        (Get I 2)
        (Get I 3)
        (Get I 0)
        (Get I 0)))
    (Concat
      (VecMAC
        (VecMAC
          (VecMAC
            (VecMAC
              (Vec4
                0
                0
                0
                (+
                  (* (Get F 1) (Get I 6))
                  (* (Get F 0) (Get I 7))))
              (Vec4 (Get F 2) 0 0 (Get F 3))
              (Vec4 (Get I 4) 0 0 (Get I 4)))
            (LitVec4
              (Get F 1)
              0
              (Get F 3)
              (Get F 4))
            (LitVec4
              (Get I 5)
              0
              (Get I 3)
              (Get I 3)))
          (LitVec4
            (Get I 2)
            (Get I 5)
            (Get I 6)
            (Get I 0))
          (LitVec4
            (Get F 4)
            (Get F 2)
            (Get F 0)
            (Get F 7)))
        (LitVec4
          (Get I 1)
          (Get I 2)
          (Get I 0)
          (Get I 1))
        (LitVec4
          (Get F 5)
          (Get F 5)
          (Get F 6)
          (Get F 6)))
      (Concat
        (VecMAC
          (VecMAC
            (VecMAC
              (VecMAC
                (Vec4
                  (+
                    (+
                      (* (Get F 1) (Get I 7))
                      (* (Get F 0) (Get I 8)))
                    (+
                      (* (Get F 4) (Get I 4))
                      (+
                        (* (Get F 3) (Get I 5))
                        (* (Get F 2) (Get I 6)))))
                  (+
                    (* (Get F 2) (Get I 7))
                    (* (Get F 1) (Get I 8)))
                  0
                  0)
                (LitVec4 (Get I 3) (Get I 4) 0 0)
                (Vec4 (Get F 5) (Get F 5) 0 0))
              (LitVec4
                (Get I 2)
                (Get I 5)
                (Get I 8)
                0)
              (LitVec4
                (Get F 6)
                (Get F 4)
                (Get F 2)
                0))
            (LitVec4
              (Get I 1)
              (Get I 2)
              (Get I 2)
              (Get I 6))
            (LitVec4
              (Get F 7)
              (Get F 7)
              (Get F 8)
              (Get F 3)))
          (LitVec4
            (Get I 0)
            (Get I 1)
            (Get I 5)
            (Get I 3))
          (LitVec4
            (Get F 8)
            (Get F 8)
            (Get F 5)
            (Get F 6)))
        (Concat
          (VecMAC
            (VecMAC
              (VecMAC
                (VecMAC
                  (VecMAC
                    (VecMul
                      (LitVec4 0 (Get F 4) 0 0)
                      (LitVec4 0 (Get I 7) 0 0))
                    (LitVec4 0 (Get F 3) 0 0)
                    (LitVec4 0 (Get I 8) 0 0))
                  (LitVec4
                    (Get F 3)
                    (Get F 5)
                    (Get F 4)
                    0)
                  (LitVec4
                    (Get I 7)
                    (Get I 6)
                    (Get I 8)
                    0))
                (LitVec4
                  (Get I 4)
                  (Get I 4)
                  (Get I 5)
                  0)
                (LitVec4
                  (Get F 6)
                  (Get F 7)
                  (Get F 7)
                  0))
              (LitVec4
                (Get F 4)
                (Get F 6)
                (Get F 5)
                (Get F 5))
              (LitVec4
                (Get I 6)
                (Get I 5)
                (Get I 7)
                (Get I 8)))
            (LitVec4
              (Get I 3)
              (Get I 3)
              (Get I 4)
              (Get I 5))
            (LitVec4
              (Get F 7)
              (Get F 8)
              (Get F 8)
              (Get F 8)))
          (Concat
            (VecMAC
              (VecMAC
                (VecMul
                  (LitVec4 0 0 (Get F 7) 0)
                  (LitVec4 0 0 (Get I 7) 0))
                (LitVec4
                  0
                  (Get I 6)
                  (Get I 8)
                  (Get I 7))
                (LitVec4
                  0
                  (Get F 7)
                  (Get F 6)
                  (Get F 8)))
              (LitVec4
                (Get F 6)
                (Get F 6)
                (Get F 8)
                (Get F 7))
              (LitVec4
                (Get I 6)
                (Get I 7)
                (Get I 6)
                (Get I 8)))
            (VecMul
              (LitVec4 (Get F 8) 0 0 0)
              (LitVec4 (Get I 8) 0 0 0))))))))


void matrix_multiply(float a_in[2 * 2], float b_in[2 * 2],
                     float c_out[2 * 2]) {
    float test[3][3];
    test[2][2];
    test[2][2] = 3.0;
    test[2][2] += test[2][2];
    for (int y = 0; y < 2; y++) {
        for (int x = 0; x < 2; x++) {
            c_out[2 * y + x] = 0;
            for (int k = 0; k < 2; k++) {
                c_out[2 * y + x] +=
                    a_in[2 * y + k] * b_in[2 * k + x];
            }
        }
    }
}

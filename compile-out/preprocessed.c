





void add_matrices(float a[3][3], float b[3][3],
                  float c[3][3]) {

    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            c[i][j] = a[i][j] + b[i][j];
        }
    }
}

void multiply_matrices(float a_in[3][3], float b_in[3][3],
                       float c_out[3][3]) {
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            float sum = 0.0;
            for (int k = 0; k < 3; k++) {
                sum += a_in[i][k] * b_in[k][j];
            }
            c_out[i][j] = sum;
        }
    }
}

void matrix_multiply(float a_in[2 * 2], float b_in[2 * 2],
                     float c_out[2 * 2]) {
    float test4d[3][3][3][3];
    test4d[2][2][2][2];
    test4d[0][0][1][0] = 3.0;
    test4d[0][0][1][0] += test4d[0][0][1][0];

    float test[3][3];
    test[1][1] = 3;
    for (int y = 0; y < 3; y++) {
        for (int x = 0; x < 3; x++) {
            test[y][x] = 1;
        }
    }



    float extra[3][3];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            float sum = 0.0;
            for (int k = 0; k < 3; k++) {
                sum += test[i][k] * test[k][j];
            }
            extra[i][j] = sum;
        }
    }


    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            extra[i][j] = extra[i][j] + extra[i][j];
        }
    }

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

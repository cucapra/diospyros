#define NCOLS 3
#define NROWS 3

// void add_matrices(float a[NCOLS][NROWS], float b[NCOLS][NROWS],
//                   float c[NCOLS][NROWS]) {
//     // assume dimensions are correct for both arrays
// for (int i = 0; i < NROWS; i++) {
//     for (int j = 0; j < NCOLS; j++) {
//         c[i][j] = a[i][j] + b[i][j];
//     }
// }
// }

// void test_add() {
//     float a[NCOLS][NROWS] = {{1, 2, 3}, {1, 2, 3}, {1, 2, 3}};
//     float b[NCOLS][NROWS] = {{3, 6, 7}, {4, 5, 8}, {3, 2, 10}};
//     float c[NCOLS][NROWS];
//     add_matrices(a, b, c);
// }

// void multiply_matrices(float a_in[NCOLS][NROWS], float b_in[NCOLS][NROWS],
//                        float c_out[NCOLS][NROWS]) {
// for (int i = 0; i < NROWS; i++) {
//     for (int j = 0; j < NCOLS; j++) {
//         float sum = 0.0;
//         for (int k = 0; k < NROWS; k++) {
//             sum += a_in[i][k] * b_in[k][j];
//         }
//         c_out[i][j] = sum;
//     }
// }
// }

// void test_multiply() {
//     float a[NCOLS][NROWS] = {{1, 2, 3}, {1, 2, 3}, {1, 2, 3}};
//     float b[NCOLS][NROWS] = {{3, 6, 7}, {4, 5, 8}, {3, 2, 10}};
//     float c[NCOLS][NROWS];
//     multiply_matrices(a, b, c);
// }

#define A_ROWS 2
#define A_COLS 2
#define B_COLS 2

void matrix_multiply(float a_in[A_ROWS * A_COLS], float b_in[A_COLS * B_COLS],
                     float c_out[A_ROWS * B_COLS]) {
    float test4d[NROWS][NCOLS][NCOLS][NCOLS];
    test4d[2][2][2][2];
    test4d[0][0][1][0] = 3.0;
    test4d[0][0][1][0] += test4d[0][0][1][0];

    float test[NROWS][NCOLS];
    test[1][1] = 3;
    for (int y = 0; y < NROWS; y++) {
        for (int x = 0; x < NCOLS; x++) {
            test[y][x] = 1;
        }
    }

    // 2d matrix multiply
    // test * test = extra
    float extra[NROWS][NCOLS];
    for (int i = 0; i < NROWS; i++) {
        for (int j = 0; j < NCOLS; j++) {
            float sum = 0.0;
            for (int k = 0; k < NROWS; k++) {
                sum += test[i][k] * test[k][j];
            }
            extra[i][j] = sum;
        }
    }

    // 2d matrix addition
    for (int i = 0; i < NROWS; i++) {
        for (int j = 0; j < NCOLS; j++) {
            extra[i][j] = extra[i][j] + extra[i][j];
        }
    }

    for (int y = 0; y < A_ROWS; y++) {
        for (int x = 0; x < B_COLS; x++) {
            c_out[B_COLS * y + x] = 0;
            for (int k = 0; k < A_COLS; k++) {
                c_out[B_COLS * y + x] +=
                    a_in[A_COLS * y + k] * b_in[B_COLS * k + x];
            }
        }
    }
}

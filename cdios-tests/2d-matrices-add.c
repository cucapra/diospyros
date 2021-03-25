#define NCOLS 3
#define NROWS 3

void add_matrices(float a[NCOLS][NROWS], float b[NCOLS][NROWS],
                  float c[NCOLS][NROWS]) {
    // assume dimensions are correct for both arrays
    for (int i = 0; i < NROWS; i++) {
        for (int j = 0; j < NCOLS; j++) {
            c[i][j] = a[i][j] + b[i][j];
        }
    }
}

void test_add() {
    float a[NCOLS][NROWS] = {{1, 2, 3}, {1, 2, 3}, {1, 2, 3}};
    float b[NCOLS][NROWS] = {{3, 6, 7}, {4, 5, 8}, {3, 2, 10}};
    float c[NCOLS][NROWS];
    add_matrices(a, b, c);
}

void multiply_matrices(float a[NCOLS][NROWS], float b[NCOLS][NROWS],
                       float c[NCOLS][NROWS]) {
    for (int i = 0; i < NROWS; i++) {
        for (int j = 0; j < NCOLS; j++) {
            float sum = 0.0;
            for (int k = 0; k < NROWS; k++) {
                sum += a[i][k] * b[k][j];
            }
            c[i][j] = sum;
        }
    }
}

void test_multiply() {
    float a[NCOLS][NROWS] = {{1, 2, 3}, {1, 2, 3}, {1, 2, 3}};
    float b[NCOLS][NROWS] = {{3, 6, 7}, {4, 5, 8}, {3, 2, 10}};
    float c[NCOLS][NROWS];
    multiply_matrices(a, b, c);
}

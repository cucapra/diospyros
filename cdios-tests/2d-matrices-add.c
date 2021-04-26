#define NCOLS 3
#define NROWS 3
#define A_ROWS 2
#define A_COLS 2
#define B_COLS 2
#define QUATERNION_DIM 4

// cross product of 2 vectors (a cross b = c)
void naive_cross_product(float lhs[3], float rhs[3], float result[3]) {
    result[0] = lhs[1] * rhs[2] - lhs[2] * rhs[1];
    result[1] = lhs[2] * rhs[0] - lhs[0] * rhs[2];
    result[2] = lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

// dot product of 2 vectors (a dot b = c)
void naive_dot_product(float a_in[QUATERNION_DIM], float b_in[QUATERNION_DIM],
                       float c_out) {
    for (int i = 0; i < QUATERNION_DIM; i++) {
        c_out += a_in[i] * b_in[i];
    }
}

// multiply c = Ab, c, b are vectors, A is a matrix
void quaternion_matrix_vec_mult(float a_in[QUATERNION_DIM][QUATERNION_DIM],
                                float b_in[QUATERNION_DIM],
                                float c_out[QUATERNION_DIM]) {
    for (int i = 0; i < QUATERNION_DIM; i++) {
        float sum = 0.0;
        for (int k = 0; k < QUATERNION_DIM; k++) {
            sum += a_in[i][k] * b_in[k];
        }
        c_out[i] = sum;
    }
}

// https://people.csail.mit.edu/bkph/articles/Quaternions.pdf
// muktuple quaternions a and b to get a quaternion c
void naive_quaternion_product(float a_in[QUATERNION_DIM],
                              float b_in[QUATERNION_DIM],
                              float c_out[QUATERNION_DIM]) {
    float A_matrix[QUATERNION_DIM][QUATERNION_DIM];
    A_matrix[0][0] = a_in[0];
    A_matrix[0][1] = a_in[1];
    A_matrix[0][2] = a_in[2];
    A_matrix[0][3] = a_in[3];

    A_matrix[1][0] = -a_in[1];
    A_matrix[1][1] = a_in[0];
    A_matrix[1][2] = a_in[3];
    A_matrix[1][3] = -a_in[2];

    A_matrix[2][0] = -a_in[2];
    A_matrix[2][1] = -a_in[3];
    A_matrix[2][2] = a_in[0];
    A_matrix[2][3] = a_in[1];

    A_matrix[3][0] = -a_in[3];
    A_matrix[3][1] = a_in[2];
    A_matrix[3][2] = -a_in[1];
    A_matrix[3][3] = a_in[0];

    quaternion_matrix_vec_mult(A_matrix, b_in, c_out);
}

void add_matrices(float a[NCOLS][NROWS], float b[NCOLS][NROWS],
                  float c[NCOLS][NROWS]) {
    // assume dimensions are correct for both arrays
    for (int i = 0; i < NROWS; i++) {
        for (int j = 0; j < NCOLS; j++) {
            c[i][j] = a[i][j] + b[i][j];
        }
    }
}

void multiply_matrices(float a_in[NCOLS][NROWS], float b_in[NCOLS][NROWS],
                       float c_out[NCOLS][NROWS]) {
    for (int i = 0; i < NROWS; i++) {
        for (int j = 0; j < NCOLS; j++) {
            float sum = 0.0;
            for (int k = 0; k < NROWS; k++) {
                sum += a_in[i][k] * b_in[k][j];
            }
            c_out[i][j] = sum;
        }
    }
}

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

    // old 1 D matrix multiplication
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

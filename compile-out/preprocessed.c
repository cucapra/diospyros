







void naive_cross_product(float lhs[3], float rhs[3], float result[3]) {
    result[0] = lhs[1] * rhs[2] - lhs[2] * rhs[1];
    result[1] = lhs[2] * rhs[0] - lhs[0] * rhs[2];
    result[2] = lhs[0] * rhs[1] - lhs[1] * rhs[0];
}


void naive_dot_product(float a_in[4], float b_in[4],
                       float c_out) {
    for (int i = 0; i < 4; i++) {
        c_out += a_in[i] * b_in[i];
    }
}


void quaternion_matrix_vec_mult(float a_in[4][4],
                                float b_in[4],
                                float c_out[4]) {
    for (int i = 0; i < 4; i++) {
        float sum = 0.0;
        for (int k = 0; k < 4; k++) {
            sum += a_in[i][k] * b_in[k];
        }
        c_out[i] = sum;
    }
}



void naive_quaternion_product(float a_in[4],
                              float b_in[4],
                              float c_out[4]) {
    float A_matrix[4][4];
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

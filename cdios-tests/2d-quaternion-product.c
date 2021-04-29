#define QUATERNION_DIM 4

// cross product of 2 vectors (a cross b = c)
void naive_cross_product(float lhs[3], float rhs[3], float result[3]) {
    result[0] = lhs[1] * rhs[2] - lhs[2] * rhs[1];
    result[1] = lhs[2] * rhs[0] - lhs[0] * rhs[2];
    result[2] = lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

/*
  Computes the point product
*/
void naive_point_product(float q[QUATERNION_DIM], float p[3], float result[3]) {
    float qvec[3] = {q[0], q[1], q[2]};
    float uv[3];
    naive_cross_product(qvec, p, uv);

    for (int i = 0; i < 3; i++) {
        uv[i] = uv[i] * 2;
    }
    float qxuv[3];
    naive_cross_product(qvec, uv, qxuv);

    for (int i = 0; i < 3; i++) {
        result[i] = p[i] + q[3] * uv[i] + qxuv[i];
    }
}

// multiply c = Ab, c, b are vectors, A is a matrix
void quaternion_matrix_vec_mult(float a[QUATERNION_DIM][QUATERNION_DIM],
                                float b[QUATERNION_DIM],
                                float c[QUATERNION_DIM]) {
    for (int i = 0; i < QUATERNION_DIM; i++) {
        float sum = 0.0;
        for (int k = 0; k < QUATERNION_DIM; k++) {
            sum += a[i][k] * b[k];
        }
        c[i] = sum;
    }
}

void naive_quaternion_product(float a_q_in[QUATERNION_DIM], float a_t_in[3],
                              float b_q_in[QUATERNION_DIM], float b_t_in[3],
                              float r_q_out[QUATERNION_DIM], float r_t_out[3]) {
    r_q_out[3] = a_q_in[3] * b_q_in[3] - a_q_in[0] * b_q_in[0] -
                 a_q_in[1] * b_q_in[1] - a_q_in[2] * b_q_in[2];
    r_q_out[0] = a_q_in[3] * b_q_in[0] + a_q_in[0] * b_q_in[3] +
                 a_q_in[1] * b_q_in[2] - a_q_in[2] * b_q_in[1];
    r_q_out[1] = a_q_in[3] * b_q_in[1] + a_q_in[1] * b_q_in[3] +
                 a_q_in[2] * b_q_in[0] - a_q_in[0] * b_q_in[2];
    r_q_out[2] = a_q_in[3] * b_q_in[2] + a_q_in[2] * b_q_in[3] +
                 a_q_in[0] * b_q_in[1] - a_q_in[1] * b_q_in[0];

    // float A_matrix[QUATERNION_DIM][QUATERNION_DIM];
    // A_matrix[0][0] = a_q_in[0];
    // A_matrix[0][1] = a_q_in[1];
    // A_matrix[0][2] = a_q_in[2];
    // A_matrix[0][3] = a_q_in[3];

    // A_matrix[1][0] = -a_q_in[1];
    // A_matrix[1][1] = a_q_in[0];
    // A_matrix[1][2] = a_q_in[3];
    // A_matrix[1][3] = -a_q_in[2];

    // A_matrix[2][0] = -a_q_in[2];
    // A_matrix[2][1] = -a_q_in[3];
    // A_matrix[2][2] = a_q_in[0];
    // A_matrix[2][3] = a_q_in[1];

    // A_matrix[3][0] = -a_q_in[3];
    // A_matrix[3][1] = a_q_in[2];
    // A_matrix[3][2] = -a_q_in[1];
    // A_matrix[3][3] = a_q_in[0];

    // quaternion_matrix_vec_mult(A_matrix, b_q_in, r_q_out);

    // naive_point_product(a_q_in, b_t_in, r_t_out);
    // for (int i = 0; i < 3; i++) {
    //     r_t_out[i] += a_t_in[i];
    // }
}

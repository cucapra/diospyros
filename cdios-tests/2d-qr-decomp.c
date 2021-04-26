#define SIZE 5

// ---------------------QR FACTORIZATION---------------------------------
float sgn(float v) { return (v > 0) - (v < 0); }

// Naive with fixed size transpose of matrix A
void naive_fixed_transpose(float a[SIZE][SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = i + 1; j < SIZE; j++) {
            float tmp = a[i][j];
            a[i][j] = a[j][i];
            a[j][i] = tmp;
        }
    }
}

// Norm of vector x (x cannot be a matrix under current implementation of
// c-meta.rkt)
// (c-meta would need to change to act differently on pointer arguments,
// including accepting a size of pointer argument)
float naive_norm(float *x, int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += pow(x[i], 2);
    }
    return sqrt(sum);
}

// Fixed Size Matrix Multiplication (A times B  = C)
void naive_fixed_matrix_multiply(float a[SIZE][SIZE], float b[SIZE][SIZE],
                                 float c[SIZE][SIZE]) {
    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            c[y][x] = 0;
            for (int k = 0; k < SIZE; k++) {
                c[y][x] += a[y][k] * b[k][x];
            }
        }
    }
}

// Fixed Size decomposition of A into Q R factorization
void naive_fixed_qr_decomp(float A_in[SIZE][SIZE], float Q_out[SIZE][SIZE],
                           float R_out[SIZE][SIZE]) {
    // copy A's contents into R
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            R_out[i][j] = A_in[i][j];
        }
    }

    // Build identity matrix of size SIZE * SIZE
    float I[SIZE][SIZE];
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i][j] = ((i == j) ? 1.0 : 0.0);
        }
    }

    // Householder
    for (int k = 0; k < SIZE - 1; k++) {
        int m = SIZE - k;

        float x[m];
        float e[m];
        for (int i = 0; i < m; i++) {
            int row = k + i;
            x[i] = R_out[row][k];
            e[i] = I[row][k];
        }

        float alpha = -sgn(x[0]) * naive_norm(x, m);

        float u[m];
        float v[m];
        for (int i = 0; i < m; i++) {
            u[i] = x[i] + alpha * e[i];
        }
        float norm_u = naive_norm(u, m);
        for (int i = 0; i < m; i++) {
            v[i] = u[i] / norm_u;
        }

        float q_min[m][m];
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < m; j++) {
                float q_min_i = ((i == j) ? 1.0 : 0.0) - 2 * v[i] * v[j];
                q_min[i][j] = q_min_i;
            }
        }

        float q_t[SIZE][SIZE];
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                float q_t_i = 0;
                if ((i < k) || (j < k)) {
                    q_t_i = (i == j) ? 1.0 : 0.0;
                } else {
                    q_t_i = q_min[(i - k)][(j - k)];
                }
                q_t[i][j] = q_t_i;
            }
        }

        if (k == 0) {
            // Q = q_t
            for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++) {
                    Q_out[i][j] = q_t[i][j];
                }
            }
            naive_fixed_matrix_multiply(q_t, A_in, R_out);  // R = q_t * A
        } else {
            float res[SIZE][SIZE];
            naive_fixed_matrix_multiply(q_t, Q_out, res);  // R = q_t * A
            // Q = res
            for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++) {
                    Q_out[i][j] = res[i][j];
                }
            }
            naive_fixed_matrix_multiply(q_t, R_out, res);  // R = q_t * A
            // R = res
            for (int i = 0; i < SIZE; i++) {
                for (int j = 0; j < SIZE; j++) {
                    R_out[i][j] = res[i][j];
                }
            }
        }
    }
    naive_fixed_transpose(Q_out);
}
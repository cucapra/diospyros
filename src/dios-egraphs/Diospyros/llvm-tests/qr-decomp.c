#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

float sgn(float v) { return (v > 0) - (v < 0); }

// Naive implementation
void naive_transpose(float *a, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            float tmp = a[i * n + j];
            a[i * n + j] = a[j * n + i];
            a[j * n + i] = tmp;
        }
    }
}

float naive_norm(float *x, int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += pow(x[i], 2);
    }
    return sqrt(sum);
}

void naive_matrix_multiply(float *a, float *b, float *c, int row1, int col1,
                           int col2) {
    for (int y = 0; y < row1; y++) {
        for (int x = 0; x < col2; x++) {
            c[col2 * y + x] = 0;
            for (int k = 0; k < col1; k++) {
                c[col2 * y + x] += a[col1 * y + k] * b[col2 * k + x];
            }
        }
    }
}

void naive_qr_decomp(float *A, float *Q, float *R, int n) {
    memcpy(R, A, sizeof(float) * n * n);

    // Build identity matrix of size n * n
    float *I = (float *)calloc(sizeof(float), n * n);
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            I[i * n + j] = (i == j);
        }
    }

    // Householder
    for (int k = 0; k < n - 1; k++) {
        int m = n - k;

        float *x = (float *)calloc(sizeof(float), m);
        float *e = (float *)calloc(sizeof(float), m);
        for (int i = 0; i < m; i++) {
            int row = k + i;
            x[i] = R[row * n + k];
            e[i] = I[row * n + k];
        }

        float alpha = -sgn(x[0]) * naive_norm(x, m);

        float *u = (float *)calloc(sizeof(float), m);
        float *v = (float *)calloc(sizeof(float), m);
        for (int i = 0; i < m; i++) {
            u[i] = x[i] + alpha * e[i];
        }
        float norm_u = naive_norm(u, m);
        for (int i = 0; i < m; i++) {
            v[i] = u[i] / norm_u;
        }

        float *q_min = (float *)calloc(sizeof(float), m * m);
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < m; j++) {
                float q_min_i = ((i == j) ? 1.0 : 0.0) - 2 * v[i] * v[j];
                q_min[i * m + j] = q_min_i;
            }
        }

        float *q_t = (float *)calloc(sizeof(float), n * n);
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                float q_t_i;
                if ((i < k) || (j < k)) {
                    q_t_i = (i == j) ? 1.0 : 0.0;
                } else {
                    q_t_i = q_min[(i - k) * m + (j - k)];
                }
                q_t[i * n + j] = q_t_i;
            }
        }

        if (k == 0) {
            memcpy(Q, q_t, sizeof(float) * n * n);      // Q = q_t
            naive_matrix_multiply(q_t, A, R, n, n, n);  // R = q_t * A
        } else {
            float *res = (float *)calloc(sizeof(float), n * n);
            naive_matrix_multiply(q_t, Q, res, n, n, n);  // R = q_t * A
            memcpy(Q, res, sizeof(float) * n * n);
            naive_matrix_multiply(q_t, R, res, n, n, n);  // R = q_t * A
            memcpy(R, res, sizeof(float) * n * n);
        }
        free(x);
        free(e);
        free(u);
        free(v);
        free(q_min);
        free(q_t);
    }
    naive_transpose(Q, n);
}

int main(void) {}
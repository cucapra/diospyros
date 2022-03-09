#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 2
#define DELTA 0.1f

float sgn(float v) __attribute__((always_inline));
float naive_norm(float *x, int m) __attribute__((always_inline));
void naive_fixed_transpose(float *a) __attribute__((always_inline));
void naive_fixed_matrix_multiply(float *a, float *b, float *c)
    __attribute__((always_inline));

float sgn(float v) { return (v > 0) - (v < 0); }

float no_opt_sgn(float v) { return (v > 0) - (v < 0); }

float naive_norm(float *x, int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += x[i] * x[i];
    }
    return sqrtf(sum);
}

float no_opt_naive_norm(float *x, int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += x[i] * x[i];
    }
    return sqrtf(sum);
}

// Naive with fixed size
void naive_fixed_transpose(float a[SIZE * SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = i + 1; j < SIZE; j++) {
            float tmp = a[i * SIZE + j];
            a[i * SIZE + j] = a[j * SIZE + i];
            a[j * SIZE + i] = tmp;
        }
    }
}

void no_opt_naive_fixed_transpose(float a[SIZE * SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = i + 1; j < SIZE; j++) {
            float tmp = a[i * SIZE + j];
            a[i * SIZE + j] = a[j * SIZE + i];
            a[j * SIZE + i] = tmp;
        }
    }
}

void naive_fixed_matrix_multiply(float a[SIZE * SIZE], float b[SIZE * SIZE],
                                 float c[SIZE * SIZE]) {
    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            c[SIZE * y + x] = 0;
            for (int k = 0; k < SIZE; k++) {
                c[SIZE * y + x] += a[SIZE * y + k] * b[SIZE * k + x];
            }
        }
    }
}

void no_opt_naive_fixed_matrix_multiply(float a[SIZE * SIZE],
                                        float b[SIZE * SIZE],
                                        float c[SIZE * SIZE]) {
    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            c[SIZE * y + x] = 0;
            for (int k = 0; k < SIZE; k++) {
                c[SIZE * y + x] += a[SIZE * y + k] * b[SIZE * k + x];
            }
        }
    }
}

void naive_fixed_qr_decomp(float A[SIZE * SIZE], float Q[SIZE * SIZE],
                           float R[SIZE * SIZE], float I[SIZE * SIZE],
                           float x[SIZE], float e[SIZE], float u[SIZE],
                           float v[SIZE], float q_min[SIZE * SIZE],
                           float q_t[SIZE * SIZE], float res[SIZE * SIZE]) {
    // OLD COMMAND: memcpy(R, A, sizeof(float) * SIZE * SIZE);
    for (int i = 0; i < SIZE * SIZE; i++) {
        R[i] = A[i];
    }

    // Build identity matrix of size SIZE * SIZE
    // OLD COMMAND: : float *I = (float *)calloc(sizeof(float), SIZE * SIZE);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
    }

    // Householder
    for (int k = 0; k < SIZE - 1; k++) {
        int m = SIZE - k;

        // OLD COMMAND: float *x = (float *)calloc(sizeof(float), m);
        // OLD COMMAND: float *e = (float *)calloc(sizeof(float), m);
        for (int i = 0; i < SIZE; i++) {
            x[i] = 0.0f;
            e[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            int row = k + i;
            x[i] = R[row * SIZE + k];
            e[i] = I[row * SIZE + k];
        }

        float alpha = -sgn(x[0]) * naive_norm(x, m);

        // OLD COMMAND: float *u = (float *)calloc(sizeof(float), m);
        // OLD COMMAND: float *v = (float *)calloc(sizeof(float), m);
        for (int i = 0; i < SIZE; i++) {
            u[i] = 0.0f;
            v[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            u[i] = x[i] + alpha * e[i];
        }
        float norm_u = naive_norm(u, m);
        for (int i = 0; i < m; i++) {
            v[i] = u[i] / (norm_u + 0.00001f);
        }

        // OLD COMMAND: float *q_min = (float *)calloc(sizeof(float), m * m);
        for (int i = 0; i < SIZE * SIZE; i++) {
            q_min[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < m; j++) {
                float q_min_i = ((i == j) ? 1.0f : 0.0f) - 2 * v[i] * v[j];
                q_min[i * m + j] = q_min_i;
            }
        }

        // OLD COMMAND: float *q_t = (float *)calloc(sizeof(float), SIZE *
        // SIZE);
        for (int i = 0; i < SIZE * SIZE; i++) {
            q_t[i] = 0.0f;
        }
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                float q_t_i;
                if ((i < k) || (j < k)) {
                    q_t_i = (i == j) ? 1.0f : 0.0f;
                } else {
                    q_t_i = q_min[(i - k) * m + (j - k)];
                }
                q_t[i * SIZE + j] = q_t_i;
            }
        }

        if (k == 0) {
            // OLD COMMAND: memcpy(Q, q_t, sizeof(float) * SIZE * SIZE);  // Q =
            // q_t
            for (int i = 0; i < SIZE * SIZE; i++) {
                Q[i] = q_t[i];
            }
            naive_fixed_matrix_multiply(q_t, A, R);  // R = q_t * A
        } else {
            // OLD COMMAND: float *res = (float *)calloc(sizeof(float), SIZE *
            // SIZE);
            for (int i = 0; i < SIZE * SIZE; i++) {
                res[i] = 0.0f;
            }
            naive_fixed_matrix_multiply(q_t, Q, res);  // R = q_t * A
            // OLD COMMAND: memcpy(Q, res, sizeof(float) * SIZE * SIZE);
            for (int i = 0; i < SIZE * SIZE; i++) {
                Q[i] = res[i];
            }
            naive_fixed_matrix_multiply(q_t, R, res);  // R = q_t * A
            // OLD COMMAND: memcpy(R, res, sizeof(float) * SIZE * SIZE);
            for (int i = 0; i < SIZE * SIZE; i++) {
                R[i] = res[i];
            }
        }
        // OLD COMMAND: free(x);
        // OLD COMMAND: free(e);
        // OLD COMMAND: free(u);
        // OLD COMMAND: free(v);
        // OLD COMMAND: free(q_min);
        // OLD COMMAND: free(q_t);
    }
    naive_fixed_transpose(Q);
}

void no_opt_naive_fixed_qr_decomp(float A[SIZE * SIZE], float Q[SIZE * SIZE],
                                  float R[SIZE * SIZE]) {
    memcpy(R, A, sizeof(float) * SIZE * SIZE);

    // Build identity matrix of size SIZE * SIZE
    float *I = (float *)calloc(sizeof(float), SIZE * SIZE);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
    }

    // Householder
    for (int k = 0; k < SIZE - 1; k++) {
        int m = SIZE - k;

        float *x = (float *)calloc(sizeof(float), m);
        float *e = (float *)calloc(sizeof(float), m);
        for (int i = 0; i < m; i++) {
            int row = k + i;
            x[i] = R[row * SIZE + k];
            e[i] = I[row * SIZE + k];
        }

        float alpha = -no_opt_sgn(x[0]) * no_opt_naive_norm(x, m);

        float *u = (float *)calloc(sizeof(float), m);
        float *v = (float *)calloc(sizeof(float), m);
        for (int i = 0; i < m; i++) {
            u[i] = x[i] + alpha * e[i];
        }
        float norm_u = no_opt_naive_norm(u, m);
        for (int i = 0; i < m; i++) {
            v[i] = u[i] / (norm_u + 0.00001f);
        }

        float *q_min = (float *)calloc(sizeof(float), m * m);
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < m; j++) {
                float q_min_i = ((i == j) ? 1.0f : 0.0f) - 2 * v[i] * v[j];
                q_min[i * m + j] = q_min_i;
            }
        }

        float *q_t = (float *)calloc(sizeof(float), SIZE * SIZE);
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                float q_t_i;
                if ((i < k) || (j < k)) {
                    q_t_i = (i == j) ? 1.0f : 0.0f;
                } else {
                    q_t_i = q_min[(i - k) * m + (j - k)];
                }
                q_t[i * SIZE + j] = q_t_i;
            }
        }

        if (k == 0) {
            memcpy(Q, q_t, sizeof(float) * SIZE * SIZE);    // Q = q_t
            no_opt_naive_fixed_matrix_multiply(q_t, A, R);  // R = q_t * A
        } else {
            float *res = (float *)calloc(sizeof(float), SIZE * SIZE);
            no_opt_naive_fixed_matrix_multiply(q_t, Q, res);  // R = q_t * A
            memcpy(Q, res, sizeof(float) * SIZE * SIZE);
            no_opt_naive_fixed_matrix_multiply(q_t, R, res);  // R = q_t * A
            memcpy(R, res, sizeof(float) * SIZE * SIZE);
        }
        free(x);
        free(e);
        free(u);
        free(v);
        free(q_min);
        free(q_t);
    }
    no_opt_naive_fixed_transpose(Q);
}

int main(void) {
    float A[SIZE * SIZE] = {1, 2, 3, 4};
    float Q[SIZE * SIZE] = {0.0f};
    float R[SIZE * SIZE] = {0.0f};
    float I[SIZE * SIZE] = {0.0f};
    float x[SIZE] = {0.0f};
    float e[SIZE] = {0.0f};
    float u[SIZE] = {0.0f};
    float v[SIZE] = {0.0f};
    float q_min[SIZE * SIZE] = {0.0f};
    float q_t[SIZE * SIZE] = {0.0f};
    float res[SIZE * SIZE] = {0.0f};
    naive_fixed_qr_decomp(A, Q, R, I, x, e, u, v, q_min, q_t, res);
    float expectedQ[SIZE * SIZE] = {0.0f};
    float expectedR[SIZE * SIZE] = {0.0f};
    no_opt_naive_fixed_qr_decomp(A, expectedQ, expectedR);

    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            printf("Q Output: %f\n", Q[i * SIZE + j]);
            printf("Expected Q Output: %f\n", expectedQ[i * SIZE + j]);
            assert(fabs(expectedQ[i] - Q[i]) < DELTA);
        }
    }
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            printf("R Output: %f\n", R[i * SIZE + j]);
            printf("Expected R Output: %f\n", expectedR[i * SIZE + j]);
            assert(fabs(expectedR[i] - R[i]) < DELTA);
        }
    }
}
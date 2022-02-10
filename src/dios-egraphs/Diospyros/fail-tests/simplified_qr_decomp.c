// Here I remove the need for using calloc and free by preallocating larger
// arrays I want to eliminate any sources of error first.
// I also remove all references to memcpy as well
// This is to isolate the error so that it is not because of an externally
// linked program

#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 2

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
void naive_fixed_transpose(float a[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = i + 1; j < SIZE; j++) {
            float tmp = a[i * SIZE + j];
            a[i * SIZE + j] = a[j * SIZE + i];
            a[j * SIZE + i] = tmp;
        }
    }
}

void no_opt_naive_fixed_transpose(float a[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = i + 1; j < SIZE; j++) {
            float tmp = a[i * SIZE + j];
            a[i * SIZE + j] = a[j * SIZE + i];
            a[j * SIZE + i] = tmp;
        }
    }
}

void naive_fixed_matrix_multiply(float a[SIZE], float b[SIZE], float c[SIZE]) {
    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            c[SIZE * y + x] = 0;
            for (int k = 0; k < SIZE; k++) {
                c[SIZE * y + x] += a[SIZE * y + k] * b[SIZE * k + x];
            }
        }
    }
}

void no_opt_naive_fixed_matrix_multiply(float a[SIZE], float b[SIZE],
                                        float c[SIZE]) {
    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            c[SIZE * y + x] = 0;
            for (int k = 0; k < SIZE; k++) {
                c[SIZE * y + x] += a[SIZE * y + k] * b[SIZE * k + x];
            }
        }
    }
}

void naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE]) {
    for (int i = 0; i < SIZE * SIZE; i++) {
        R[i] = A[i];
    }

    // Build identity matrix of size SIZE * SIZE
    // No Calloc is used here.
    float I[SIZE * SIZE] = {0.0f};
    // float *I = (float *)calloc(sizeof(float), SIZE * SIZE);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
    }

    // Householder
    for (int k = 0; k < SIZE - 1; k++) {
        int32_t m = SIZE - k;

        float x[m];
        for (int i = 0; i < m; i++) {
            x[i] = 0.0f;
        }
        float e[m];
        for (int i = 0; i < m; i++) {
            e[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            int row = k + i;
            x[i] = 1.0f;
            e[i] = 2.0f;
        }

        float alpha = -sgn(x[0]) * naive_norm(x, m);

        // float u[SIZE] = {0};
        // float v[SIZE] = {0};
        // for (int i = 0; i < m; i++) {
        //     u[i] = x[i] + alpha * e[i];
        // }
        // float norm_u = naive_norm(u, m);
        // for (int i = 0; i < m; i++) {
        //     v[i] = u[i] / (norm_u + 0.00001f);
        // }

        // float q_min[m * m];
        // for (int i = 0; i < m; i++) {
        //     for (int j = 0; j < m; j++) {
        //         q_min[i * m + j] = 0.0f;
        //     }
        // }
        // for (int i = 0; i < m; i++) {
        //     for (int j = 0; j < m; j++) {
        //         float q_min_i = ((i == j) ? 1.0f : 0.0f) - 2 * v[i] * v[j];
        //         q_min[i * m + j] = q_min_i;
        //     }
        // }

        // float q_t[SIZE * SIZE] = {0};
        // for (int i = 0; i < SIZE; i++) {
        //     for (int j = 0; j < SIZE; j++) {
        //         float q_t_i;
        //         if ((i < k) || (j < k)) {
        //             q_t_i = (i == j) ? 1.0f : 0.0f;
        //         } else {
        //             q_t_i = q_min[(i - k) * m + (j - k)];
        //         }
        //         q_t[i * SIZE + j] = q_t_i;
        //     }
        // }
        float q_t[SIZE * SIZE] = {alpha};
        if (k == 0) {
            for (int i = 0; i < SIZE * SIZE; i++) {
                Q[i] = q_t[i];
            }
            naive_fixed_matrix_multiply(q_t, A, R);  // R = q_t * A
        }
        //  else {
        //     float res[SIZE * SIZE] = {0.0f};
        //     naive_fixed_matrix_multiply(q_t, Q, res);  // R = q_t * A
        //     for (int i = 0; i < SIZE * SIZE; i++) {
        //         Q[i] = res[i];
        //     }
        //     naive_fixed_matrix_multiply(q_t, R, res);  // R = q_t * A
        //     for (int i = 0; i < SIZE * SIZE; i++) {
        //         R[i] = res[i];
        //     }
        // }
    }
    naive_fixed_transpose(Q);
}

void no_opt_naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE]) {
    for (int i = 0; i < SIZE * SIZE; i++) {
        R[i] = A[i];
    }

    float I[SIZE * SIZE] = {0.0f};
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
    }

    // Householder
    for (int k = 0; k < SIZE - 1; k++) {
        int32_t m = SIZE - k;

        float x[m];
        for (int i = 0; i < m; i++) {
            x[i] = 0.0f;
        }
        float e[m];
        for (int i = 0; i < m; i++) {
            e[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            int row = k + i;
            x[i] = 1.0f;
            e[i] = 2.0f;
        }

        float alpha = -no_opt_sgn(x[0]) * no_opt_naive_norm(x, m);

        // float u[SIZE] = {0};
        // float v[SIZE] = {0};
        // for (int i = 0; i < m; i++) {
        //     u[i] = x[i] + alpha * e[i];
        // }
        // float norm_u = naive_norm(u, m);
        // for (int i = 0; i < m; i++) {
        //     v[i] = u[i] / (norm_u + 0.00001f);
        // }

        // float q_min[m * m];
        // for (int i = 0; i < m; i++) {
        //     for (int j = 0; j < m; j++) {
        //         q_min[i * m + j] = 0.0f;
        //     }
        // }
        // for (int i = 0; i < m; i++) {
        //     for (int j = 0; j < m; j++) {
        //         float q_min_i = ((i == j) ? 1.0f : 0.0f) - 2 * v[i] * v[j];
        //         q_min[i * m + j] = q_min_i;
        //     }
        // }

        // float q_t[SIZE * SIZE] = {0};
        // for (int i = 0; i < SIZE; i++) {
        //     for (int j = 0; j < SIZE; j++) {
        //         float q_t_i;
        //         if ((i < k) || (j < k)) {
        //             q_t_i = (i == j) ? 1.0f : 0.0f;
        //         } else {
        //             q_t_i = q_min[(i - k) * m + (j - k)];
        //         }
        //         q_t[i * SIZE + j] = q_t_i;
        //     }
        // }

        float q_t[SIZE * SIZE] = {alpha};
        if (k == 0) {
            for (int i = 0; i < SIZE * SIZE; i++) {
                Q[i] = q_t[i];
            }
            no_opt_naive_fixed_matrix_multiply(q_t, A, R);  // R = q_t * A
        }
        // else {
        //     float res[SIZE * SIZE] = {0.0f};
        //     no_opt_naive_fixed_matrix_multiply(q_t, Q, res);  // R = q_t * A
        //     for (int i = 0; i < SIZE * SIZE; i++) {
        //         Q[i] = res[i];
        //     }
        //     no_opt_naive_fixed_matrix_multiply(q_t, R, res);  // R = q_t * A
        //     for (int i = 0; i < SIZE * SIZE; i++) {
        //         R[i] = res[i];
        //     }
        // }
    }
    no_opt_naive_fixed_transpose(Q);
}

int main(void) {
    float A[SIZE * SIZE] = {1, 2, 3, 4};
    float Q[SIZE * SIZE] = {0, 0, 0, 0};
    float R[SIZE * SIZE] = {0, 0, 0, 0};
    naive_fixed_qr_decomp(A, Q, R);
    float expectedQ[SIZE * SIZE] = {0, 0, 0, 0};
    float expectedR[SIZE * SIZE] = {0, 0, 0, 0};
    no_opt_naive_fixed_qr_decomp(A, expectedQ, expectedR);

    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            printf("Q Output: %f\n", Q[i * SIZE + j]);
            printf("Expected Q Output: %f\n", expectedQ[i * SIZE + j]);
        }
    }
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            printf("R Output: %f\n", R[i * SIZE + j]);
            printf("Expected R Output: %f\n", expectedR[i * SIZE + j]);
        }
    }
}
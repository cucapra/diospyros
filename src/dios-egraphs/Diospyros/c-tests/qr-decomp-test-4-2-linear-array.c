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

void naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE],
                           float I[SIZE], float x[SIZE], float e[SIZE],
                           float q_t[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        R[i] = A[i];
    }

    for (int i = 0; i < SIZE; i++) {
        I[i] = 1.0f;
    }

    // Householder
    for (int k = 0; k < SIZE - 1; k++) {
        int m = SIZE - k;

        for (int i = 0; i < m; i++) {
            x[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            e[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            x[i] = 1.0f;
            e[i] = 2.0f;
        }

        float alpha = -sgn(x[0]) * naive_norm(x, m);

        for (int i = 0; i < SIZE; i++) {
            q_t[i] = alpha;
        }
        if (k == 0) {
            for (int i = 0; i < SIZE; i++) {
                Q[i] = q_t[i];
            }
        }
    }
}

void no_opt_naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE],
                                  float I[SIZE], float x[SIZE], float e[SIZE],
                                  float q_t[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        R[i] = A[i];
    }

    for (int i = 0; i < SIZE; i++) {
        I[i] = 1.0f;
    }

    // Householder
    for (int k = 0; k < SIZE - 1; k++) {
        int m = SIZE - k;

        for (int i = 0; i < m; i++) {
            x[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            e[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            x[i] = 1.0f;
            e[i] = 2.0f;
        }

        float alpha = -no_opt_sgn(x[0]) * no_opt_naive_norm(x, m);

        for (int i = 0; i < SIZE; i++) {
            q_t[i] = alpha;
        }
        if (k == 0) {
            for (int i = 0; i < SIZE; i++) {
                Q[i] = q_t[i];
            }
        }
    }
}

int main(void) {
    float A[SIZE] = {1.0f, 2.0f};
    float Q[SIZE] = {0.0f};
    float R[SIZE] = {1.0f};
    float i[SIZE] = {0.0f};
    float x[SIZE] = {0.0f};
    float e[SIZE] = {0.0f};
    float q_t[SIZE] = {0.0f};
    naive_fixed_qr_decomp(A, Q, R, i, x, e, q_t);
    float expectedQ[SIZE] = {0.0f};
    float expectedR[SIZE] = {1.0f};
    float expectedi[SIZE] = {0.0f};
    float expectedx[SIZE] = {0.0f};
    float expectede[SIZE] = {0.0f};
    float expectedq_t[SIZE] = {0.0f};
    no_opt_naive_fixed_qr_decomp(A, expectedQ, expectedR, expectedi, expectedx,
                                 expectede, expectedq_t);

    for (int i = 0; i < SIZE; i++) {
        printf("Q Output: %f\n", Q[i]);
        printf("Expected Q Output: %f\n", expectedQ[i]);
        assert(fabs(Q[i] - expectedQ[i]) < DELTA);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("R Output: %f\n", R[i]);
        printf("Expected R Output: %f\n", expectedR[i]);
        assert(fabs(R[i] - expectedR[i]) < DELTA);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("Q_T Output: %f\n", q_t[i]);
        printf("Expected Q_T Output: %f\n", expectedq_t[i]);
        assert(fabs(q_t[i] - expectedq_t[i]) < DELTA);
    }
}
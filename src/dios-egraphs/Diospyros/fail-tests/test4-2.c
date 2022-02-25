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

void naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE],
                           float I[SIZE * SIZE], float x[SIZE], float e[SIZE],
                           float q_t[SIZE * SIZE]) {
    for (int i = 0; i < SIZE * SIZE; i++) {
        R[i] = A[i];
    }

    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
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

        for (int i = 0; i < SIZE * SIZE; i++) {
            q_t[i] = alpha;
        }
        if (k == 0) {
            for (int i = 0; i < SIZE * SIZE; i++) {
                Q[i] = q_t[i];
            }
            naive_fixed_matrix_multiply(q_t, A, R);  // R = q_t * A
        }
    }
    naive_fixed_transpose(Q);
}

void no_opt_naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE],
                                  float I[SIZE * SIZE], float x[SIZE],
                                  float e[SIZE], float q_t[SIZE * SIZE]) {
    for (int i = 0; i < SIZE * SIZE; i++) {
        R[i] = A[i];
    }

    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
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

        for (int i = 0; i < SIZE * SIZE; i++) {
            q_t[i] = alpha;
        }
        if (k == 0) {
            for (int i = 0; i < SIZE * SIZE; i++) {
                Q[i] = q_t[i];
            }
            no_opt_naive_fixed_matrix_multiply(q_t, A, R);  // R = q_t * A
        }
    }
    no_opt_naive_fixed_transpose(Q);
}

int main(void) {
    float A[SIZE * SIZE] = {1.0f, 2.0f, 3.0f, 4.0f};
    float Q[SIZE * SIZE] = {0.0f};
    float R[SIZE * SIZE] = {0.0f};
    float i[SIZE * SIZE] = {0.0f};
    float x[SIZE] = {0.0f};
    float e[SIZE] = {0.0f};
    float q_t[SIZE * SIZE] = {0.0f};
    naive_fixed_qr_decomp(A, Q, R, i, x, e, q_t);
    float expectedQ[SIZE * SIZE] = {0.0f};
    float expectedR[SIZE * SIZE] = {0.0f};
    float expectedi[SIZE * SIZE] = {0.0f};
    float expectedx[SIZE] = {0.0f};
    float expectede[SIZE] = {0.0f};
    float expectedq_t[SIZE * SIZE] = {0.0f};
    no_opt_naive_fixed_qr_decomp(A, expectedQ, expectedR, expectedi, expectedx,
                                 expectede, expectedq_t);

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
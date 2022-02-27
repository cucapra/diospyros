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

#define SIZE 4
#define DELTA 0.1f

float sgn(float v) __attribute__((always_inline));
float naive_norm(float *x, int m) __attribute__((always_inline));
void naive_fixed_transpose(float *a) __attribute__((always_inline));
void naive_fixed_matrix_multiply(float *a, float *b, float *c)
    __attribute__((always_inline));

float sgn(float v) { return v; }

float no_opt_sgn(float v) { return v; }

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

void naive_fixed_qr_decomp(float Q[SIZE], float x[SIZE], float q_t[SIZE]) {
    // for (int i = 0; i < SIZE; i++) {
    //     R[i] = A[i];
    // }

    // for (int i = 0; i < SIZE; i++) {
    //     I[i] = 1.0f;
    // }

    // Householder
    // for (int k = 0; k < SIZE - 1; k++) {
    // int k = 0;
    // int m = SIZE - k;

    float alpha = -sgn(x[0]);

    for (int i = 0; i < SIZE; i++) {
        q_t[i] = alpha;
    }
    // if (k == 0) {
    for (int i = 0; i < SIZE; i++) {
        Q[i] = q_t[i];
    }
    // }
    // }
}

void no_opt_naive_fixed_qr_decomp(float Q[SIZE], float x[SIZE],
                                  float q_t[SIZE]) {
    // for (int i = 0; i < SIZE; i++) {
    //     R[i] = A[i];
    // }

    // for (int i = 0; i < SIZE; i++) {
    //     I[i] = 1.0f;
    // }

    // Householder
    // for (int k = 0; k < SIZE - 1; k++) {
    // int k = 0;
    // int m = SIZE - k;

    float alpha = -no_opt_sgn(x[0]);

    for (int i = 0; i < SIZE; i++) {
        q_t[i] = alpha;
    }
    // if (k == 0) {
    for (int i = 0; i < SIZE; i++) {
        Q[i] = q_t[i];
    }
    // }
    // }
}

int main(void) {
    float A[SIZE] = {1.1f, 2.1f, 3.1f, 4.1f};
    float Q[SIZE] = {0.0f};
    for (int i = 0; i < SIZE; i++) {
        Q[i] = 0.0f;
    }
    float R[SIZE] = {1.0f};
    float i[SIZE] = {0.0f};
    float x[SIZE] = {1.2f, 1.3f, 1.4f, 1.5f};
    float e[SIZE] = {0.0f};
    float q_t[SIZE] = {0.0f};
    naive_fixed_qr_decomp(Q, x, q_t);
    float expectedQ[SIZE] = {0.0f};
    for (int i = 0; i < SIZE; i++) {
        expectedQ[i] = 0.0f;
    }
    float expectedR[SIZE] = {1.0f};
    float expectedi[SIZE] = {0.0f};
    float expectedx[SIZE] = {1.2f, 1.3f, 1.4f, 1.5f};
    float expectede[SIZE] = {0.0f};
    float expectedq_t[SIZE] = {0.0f};
    no_opt_naive_fixed_qr_decomp(expectedQ, expectedx, expectedq_t);

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
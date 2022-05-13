#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 5
#define DELTA 0.1f

float sgn(float v) __attribute__((always_inline));
float naive_norm(float *x, int m) __attribute__((always_inline));

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

void sample_test(float x[SIZE], float A[SIZE]) {
    for (int k = 0; k < SIZE; k++) {
        float alpha = -sgn(x[k]) * naive_norm(x, k);
        A[k] = alpha;
    }
}

void no_opt_sample_test(float x[SIZE], float A[SIZE]) {
    for (int k = 0; k < SIZE; k++) {
        float alpha = -no_opt_sgn(x[k]) * no_opt_naive_norm(x, k);
        A[k] = alpha;
    }
}

int main(void) {
    float x[SIZE] = {1, -1, 2, 3, 5};
    float A[SIZE] = {0};
    sample_test(x, A);
    float expectedA[SIZE] = {0};
    no_opt_sample_test(x, expectedA);
    for (int i = 0; i < SIZE; i++) {
        printf("A Output: %f\n", A[i]);
        printf("Expected A Output: %f\n", expectedA[i]);
        assert(fabs(expectedA[i] - A[i]) < DELTA);
    }
}
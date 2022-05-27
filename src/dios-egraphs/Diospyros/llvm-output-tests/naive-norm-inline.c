#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 5
#define DELTA 0.1f

float naive_norm(float *x, int m) __attribute__((always_inline));

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

void sample_test(float A[SIZE], float B[SIZE - 1]) {
    B[0] = naive_norm(A, SIZE);
}

void no_opt_sample_test(float A[SIZE], float B[SIZE - 1]) {
    B[0] = no_opt_naive_norm(A, SIZE);
}

int main(void) {
    float A[SIZE] = {1, 2, 3, 4, 5};
    float B[SIZE - 1] = {0};
    sample_test(A, B);
    float expectedA[SIZE] = {1, 2, 3, 4, 5};
    float expectedB[SIZE] = {0};
    no_opt_sample_test(expectedA, expectedB);
    for (int i = 0; i < SIZE - 1; i++) {
        printf("B Output: %f\n", B[i]);
        printf("Expected B Output: %f\n", expectedB[i]);
        assert(fabs(expectedB[i] - B[i]) < DELTA);
    }
}
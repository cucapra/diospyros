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

float sgn(float v) { return (v > 0) - (v < 0); }

float no_opt_sgn(float v) { return (v > 0) - (v < 0); }

void sample_test(float A[SIZE], float B[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        B[i] = sgn(A[i]);
    }
}

void no_opt_sample_test(float A[SIZE], float B[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        B[i] = no_opt_sgn(A[i]);
    }
}

int main(void) {
    float A[SIZE] = {1, -2, 0, -4, 5};
    float B[SIZE] = {0};
    sample_test(A, B);
    float expectedA[SIZE] = {1, -2, 0, -4, 5};
    float expectedB[SIZE] = {0};
    no_opt_sample_test(expectedA, expectedB);
    for (int i = 0; i < SIZE; i++) {
        printf("B Output: %f\n", B[i]);
        printf("Expected B Output: %f\n", expectedB[i]);
        assert(fabs(expectedB[i] - B[i]) < DELTA);
    }
}
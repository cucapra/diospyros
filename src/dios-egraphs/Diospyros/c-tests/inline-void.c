#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 10
#define DELTA 0.1f

void test_inline(float A[SIZE], float B[SIZE], int n)
    __attribute__((always_inline));

void no_opt_test_inline(float A[SIZE], float B[SIZE], int n) {
    for (int i = 0; i < n; i++) {
        B[i] = 2 * A[i];
    }
}

void no_opt_test(float A[SIZE], float B[SIZE]) {
    no_opt_test_inline(A, B, SIZE);
}

void test_inline(float A[SIZE], float B[SIZE], int n) {
    for (int i = 0; i < n; i++) {
        B[i] = 2 * A[i];
    }
}

void test(float A[SIZE], float B[SIZE]) { test_inline(A, B, SIZE); }

int main() {
    float A[SIZE] = {1.0f};
    float expectedA[SIZE] = {1.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] = 1.0f;
        expectedA[i] = 1.0f;
    }
    float B[SIZE] = {0.0f};
    float expectedB[SIZE] = {0.0f};
    for (int i = 0; i < SIZE; i++) {
        B[i] = 0.0f;
        expectedB[i] = 0.0f;
    }
    test(A, B);
    no_opt_test(expectedA, expectedB);
    for (int i = 0; i < SIZE; i++) {
        printf("B Output: %f\n", B[i]);
        printf("Expected B Output: %f\n", expectedB[i]);
        assert(fabs(expectedB[i] - B[i]) < DELTA);
    }
    return 0;
}
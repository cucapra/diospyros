#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 5
#define DELTA 0.1f

float test_inline(float A[SIZE], float B[SIZE], int n)
    __attribute__((always_inline));

float no_opt_test_inline(float A[SIZE], float B[SIZE], int n) {
    for (int i = 0; i < n; i++) {
        B[i] = 2 * A[i];
    }
    float sum = 0.0f;
    for (int i = 0; i < n; i++) {
        sum += B[i];
    }
    return sum;
}

void no_opt_test(float A[SIZE], float B[SIZE], float C[SIZE]) {
    float result = no_opt_test_inline(A, B, SIZE);
    for (int i = 0; i < SIZE; i++) {
        C[i] = result;
    }
}

float test_inline(float A[SIZE], float B[SIZE], int n) {
    for (int i = 0; i < n; i++) {
        B[i] = 2 * A[i];
    }
    float sum = 0.0f;
    for (int i = 0; i < n; i++) {
        sum += B[i];
    }
    return sum;
}

void test(float A[SIZE], float B[SIZE], float C[SIZE]) {
    float result = test_inline(A, B, SIZE);
    for (int i = 0; i < SIZE; i++) {
        C[i] = result;
    }
}

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
    float C[SIZE] = {0.0f};
    float expectedC[SIZE] = {0.0f};
    for (int i = 0; i < SIZE; i++) {
        C[i] = 0.0f;
        expectedC[i] = 0.0f;
    }
    test(A, B, C);
    no_opt_test(expectedA, expectedB, expectedC);
    for (int i = 0; i < SIZE; i++) {
        printf("C Output: %f\n", C[i]);
        printf("Expected C Output: %f\n", expectedC[i]);
        assert(fabs(expectedC[i] - C[i]) < DELTA);
    }
    return 0;
}
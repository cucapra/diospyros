#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 2
#define DELTA 0.1f

void test(float A[SIZE], float B[SIZE], float C[SIZE]) {
    float x[SIZE] = {[0 ... SIZE - 1] = 3.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] += x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        C[i] += A[i];
    }
    for (int i = 0; i < SIZE; i++) {
        B[i] -= x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        C[i] += B[i];
    }
}

void no_opt_test(float A[SIZE], float B[SIZE], float C[SIZE]) {
    float x[SIZE] = {[0 ... SIZE - 1] = 3.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] += x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        C[i] += A[i];
    }
    for (int i = 0; i < SIZE; i++) {
        B[i] -= x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        C[i] += B[i];
    }
}

int main() {
    float A[SIZE] = {[0 ... SIZE - 1] = 1.0f};
    float B[SIZE] = {[0 ... SIZE - 1] = 2.0f};
    float C[SIZE] = {[0 ... SIZE - 1] = 0.0f};
    float expectedA[SIZE] = {[0 ... SIZE - 1] = 1.0f};
    float expectedB[SIZE] = {[0 ... SIZE - 1] = 2.0f};
    float expectedC[SIZE] = {[0 ... SIZE - 1] = 0.0f};
    test(A, B, C);
    no_opt_test(expectedA, expectedB, expectedC);
    for (int i = 0; i < SIZE; i++) {
        printf("A Output: %f\n", A[i]);
        printf("expected: %f\n", expectedA[i]);
        assert(fabs(expectedA[i] - A[i]) < DELTA);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("B Output: %f\n", B[i]);
        printf("expected: %f\n", expectedB[i]);
        assert(fabs(expectedB[i] - B[i]) < DELTA);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("C Output: %f\n", C[i]);
        printf("expected: %f\n", expectedC[i]);
        assert(fabs(expectedC[i] - C[i]) < DELTA);
    }
    return 0;
}

#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 2
#define DELTA 0.1f

#define SIZE 10

void test(float A[SIZE], float B[SIZE], float C[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {[0 ... SIZE - 1] = 0.0f};
        for (int i = 0; i < SIZE; i++) {
            x[i] = (float)i;
        }
        C[i] = A[i] + x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {[0 ... SIZE - 1] = 0.0f};
        for (int i = 0; i < SIZE; i++) {
            x[i] = (float)i;
        }
        C[i] = B[i] - x[i];
    }
}

void no_opt_test(float A[SIZE], float B[SIZE], float C[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {[0 ... SIZE - 1] = 0.0f};
        for (int i = 0; i < SIZE; i++) {
            x[i] = (float)i;
        }
        C[i] = A[i] + x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {[0 ... SIZE - 1] = 0.0f};
        for (int i = 0; i < SIZE; i++) {
            x[i] = (float)i;
        }
        C[i] = B[i] - x[i];
    }
}

int main() {
    float A[SIZE] = {[0 ... SIZE - 1] = 1.0f};
    float B[SIZE] = {[0 ... SIZE - 1] = 2.0f};
    float C[SIZE] = {[0 ... SIZE - 1] = 0.0f};
    float expectedC[SIZE] = {[0 ... SIZE - 1] = 0.0f};
    test(A, B, C);
    no_opt_test(A, B, expectedC);
    for (int i = 0; i < SIZE; i++) {
        printf("C Output: %f\n", C[i]);
        printf("expected: %f\n", expectedC[i]);
        assert(fabs(expectedC[i] - C[i]) < DELTA);
    }
    return 0;
}

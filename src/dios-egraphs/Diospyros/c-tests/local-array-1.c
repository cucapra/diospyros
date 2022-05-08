#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 10
#define DELTA 0.1f

void test(float A[SIZE]) {
    float x[SIZE] = {[0 ... SIZE - 1] = 3.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] = x[i];
    }
}

void no_opt_test(float A[SIZE]) {
    float x[SIZE] = {[0 ... SIZE - 1] = 3.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] = x[i];
    }
}

int main() {
    float A[SIZE] = {[0 ... SIZE - 1] = 1.0f};
    float expectedA[SIZE] = {[0 ... SIZE - 1] = 1.0f};
    test(A);
    no_opt_test(expectedA);
    for (int i = 0; i < SIZE; i++) {
        printf("A Output: %f\n", A[i]);
        printf("expected: %f\n", expectedA[i]);
        assert(fabs(expectedA[i] - A[i]) < DELTA);
    }
    return 0;
}

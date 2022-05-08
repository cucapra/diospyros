#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 10
#define DELTA 0.1f

void test(float A[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {[0 ... SIZE - 1] = 0.0f};
        for (int j = 0; j < SIZE; j++) {
            x[j] = 1.0f;
        }
        float sum = 0.0f;
        for (int j = 0; j < SIZE; j++) {
            sum += x[j];
        }
        A[i] = sum;
    }
}

void no_opt_test(float A[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {[0 ... SIZE - 1] = 0.0f};
        for (int j = 0; j < SIZE; j++) {
            x[j] = 1.0f;
        }
        float sum = 0.0f;
        for (int j = 0; j < SIZE; j++) {
            sum += x[j];
        }
        A[i] = sum;
    }
}

int main() {
    float A[SIZE] = {[0 ... SIZE - 1] = 0.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] = (float)i;
    }
    float expectedA[SIZE] = {[0 ... SIZE - 1] = 0.0f};
    for (int i = 0; i < SIZE; i++) {
        expectedA[i] = (float)i;
    }
    test(A);
    no_opt_test(expectedA);
    for (int i = 0; i < SIZE; i++) {
        printf("A Output: %f\n", A[i]);
        printf("expected: %f\n", expectedA[i]);
        assert(fabs(expectedA[i] - A[i]) < DELTA);
    }
    return 0;
}

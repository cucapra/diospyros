#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 1

void test(float A[SIZE], float B[SIZE], float C[SIZE]) {
    float x[SIZE] = {[0 ... SIZE - 1] = 3.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] += x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        C[i] *= A[i];
    }
    for (int i = 0; i < SIZE; i++) {
        B[i] -= x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        C[i] *= B[i];
    }
}

int main() {
    float A[SIZE] = {[0 ... SIZE - 1] = 1.0f};
    float B[SIZE] = {[0 ... SIZE - 1] = 2.0f};
    float C[SIZE] = {[0 ... SIZE - 1] = 0.0f};
    test(A, B, C);
    for (int i = 0; i < SIZE; i++) {
        printf("A Output: %f\n", A[i]);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("B Output: %f\n", B[i]);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("C Output: %f\n", C[i]);
    }
    return 0;
}

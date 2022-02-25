#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 10

void test(float A[SIZE], float B[SIZE], float C[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {(float)i};
        C[i] = A[i] + x[i];
    }
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {(float)i};
        C[i] = B[i] - x[i];
    }
}

int main() {
    float A[SIZE] = {1.0f};
    float B[SIZE] = {2.0f};
    float C[SIZE] = {0.0f};
    test(A, B, C);
    for (int i = 0; i < SIZE; i++) {
        printf("C Output: %f\n", C[i]);
    }
    return 0;
}

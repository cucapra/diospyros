#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 2
#define DELTA 0.1

void naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE]) {
    memcpy(R, A, sizeof(float) * SIZE * SIZE);

    // Build identity matrix of size SIZE * SIZE
    float *I = (float *)calloc(sizeof(float), SIZE * SIZE);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
    }
}

void no_opt_naive_fixed_qr_decomp(float A[SIZE], float Q[SIZE], float R[SIZE]) {
    memcpy(R, A, sizeof(float) * SIZE * SIZE);

    // Build identity matrix of size SIZE * SIZE
    float *I = (float *)calloc(sizeof(float), SIZE * SIZE);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
    }
}

int main(void) {
    float A[SIZE * SIZE] = {0, 1, 2, 3};
    float Q[SIZE * SIZE] = {0, 1, 2, 3};
    float R[SIZE * SIZE] = {0, 1, 2, 3};
    float AExpected[SIZE * SIZE] = {0, 1, 2, 3};
    float QExpected[SIZE * SIZE] = {0, 1, 2, 3};
    float RExpected[SIZE * SIZE] = {0, 1, 2, 3};
    naive_fixed_qr_decomp(A, Q, R);
    no_opt_naive_fixed_qr_decomp(AExpected, QExpected, RExpected);
    for (int i = 0; i < SIZE * SIZE; i++) {
        printf("Expected Q: %f\n", QExpected[i]);
        printf("Actual Q: %f\n", Q[i]);
        assert(fabsf(QExpected[i] - Q[i]) < DELTA);
    }
    for (int i = 0; i < SIZE * SIZE; i++) {
        printf("Expected R: %f\n", RExpected[i]);
        printf("Actual R: %f\n", R[i]);
        assert(fabsf(RExpected[i] - R[i]) < DELTA);
    }
    for (int i = 0; i < SIZE * SIZE; i++) {
        printf("Expected A: %f\n", AExpected[i]);
        printf("Actual A: %f\n", A[i]);
        assert(fabsf(AExpected[i] - A[i]) < DELTA);
    }
}
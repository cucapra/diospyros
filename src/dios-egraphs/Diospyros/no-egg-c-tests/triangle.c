#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 2
#define DELTA 0.1

// Triangle Access Pattern Test

void lower_triangle(float A[SIZE * SIZE], float B[SIZE * SIZE],
                    float C[SIZE * SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < i; j++) {
            C[i + SIZE * j] = A[i + SIZE * j] + B[i + SIZE * j];
        }
    }
}

void no_opt_lower_triangle(float A[SIZE * SIZE], float B[SIZE * SIZE],
                           float C[SIZE * SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < i; j++) {
            C[i + SIZE * j] = A[i + SIZE * j] + B[i + SIZE * j];
        }
    }
}

void upper_triangle(float A[SIZE * SIZE], float B[SIZE * SIZE],
                    float C[SIZE * SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = i; j < SIZE; j++) {
            C[i + SIZE * j] = A[i + SIZE * j] + B[i + SIZE * j];
        }
    }
}

void no_opt_upper_triangle(float A[SIZE * SIZE], float B[SIZE * SIZE],
                           float C[SIZE * SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = i; j < SIZE; j++) {
            C[i + SIZE * j] = A[i + SIZE * j] + B[i + SIZE * j];
        }
    }
}

int main(void) {
    float A1[SIZE * SIZE] = {0, 1, 2, 3};
    float B1[SIZE * SIZE] = {0, 1, 2, 3};
    float C1[SIZE * SIZE] = {0, 1, 2, 3};

    float A1Expected[SIZE * SIZE] = {0, 1, 2, 3};
    float B1Expected[SIZE * SIZE] = {0, 1, 2, 3};
    float C1Expected[SIZE * SIZE] = {0, 1, 2, 3};

    lower_triangle(A1, B1, C1);
    no_opt_lower_triangle(A1Expected, B1Expected, C1Expected);

    for (int i = 0; i < SIZE * SIZE; i++) {
        printf("A: %f\n", A1[i]);
        printf("A Expected: %f\n", A1Expected[i]);
        printf("B: %f\n", B1[i]);
        printf("B Expected: %f\n", B1Expected[i]);
        printf("C: %f\n", C1[i]);
        printf("C Expected: %f\n", C1Expected[i]);

        assert(fabsf(A1[i] - A1Expected[i]) < DELTA);
        assert(fabsf(B1[i] - B1Expected[i]) < DELTA);
        assert(fabsf(C1[i] - C1Expected[i]) < DELTA);
    }

    float A2[SIZE * SIZE] = {0, 1, 2, 3};
    float B2[SIZE * SIZE] = {0, 1, 2, 3};
    float C2[SIZE * SIZE] = {0, 1, 2, 3};

    float A2Expected[SIZE * SIZE] = {0, 1, 2, 3};
    float B2Expected[SIZE * SIZE] = {0, 1, 2, 3};
    float C2Expected[SIZE * SIZE] = {0, 1, 2, 3};

    upper_triangle(A2, B2, C2);
    no_opt_upper_triangle(A2Expected, B2Expected, C2Expected);

    for (int i = 0; i < SIZE * SIZE; i++) {
        printf("A: %f\n", A2[i]);
        printf("A Expected: %f\n", A2Expected[i]);
        printf("B: %f\n", B2[i]);
        printf("B Expected: %f\n", B2Expected[i]);
        printf("C: %f\n", C2[i]);
        printf("C Expected: %f\n", C2Expected[i]);

        assert(fabsf(A2[i] - A2Expected[i]) < DELTA);
        assert(fabsf(B2[i] - B2Expected[i]) < DELTA);
        assert(fabsf(C2[i] - C2Expected[i]) < DELTA);
    }
}
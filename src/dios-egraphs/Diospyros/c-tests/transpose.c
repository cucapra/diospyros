#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 10
#define DELTA 0.1f

void naive_transpose(float a[SIZE * SIZE], int n) {
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            float tmp = a[i * n + j];
            a[i * n + j] = a[j * n + i];
            a[j * n + i] = tmp;
        }
    }
}

void no_opt_naive_transpose(float a[SIZE * SIZE], int n) {
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            float tmp = a[i * n + j];
            a[i * n + j] = a[j * n + i];
            a[j * n + i] = tmp;
        }
    }
}

int main() {
    float calculated[SIZE * SIZE] = {0};
    for (int i = 0; i < SIZE * SIZE; i++) {
        if (i % 2 == 0) {
            calculated[i] = 1.0f;
        } else {
            calculated[i] = 0.0f;
        }
    }
    float expected[SIZE * SIZE] = {0};
    for (int i = 0; i < SIZE * SIZE; i++) {
        if (i % 2 == 0) {
            expected[i] = 1.0f;
        } else {
            expected[i] = 0.0f;
        }
    }
    naive_transpose(calculated, SIZE);
    no_opt_naive_transpose(expected, SIZE);
    for (int i = 0; i < SIZE * SIZE; i++) {
        printf("A Transpose Calculated: %f\n", calculated[i]);
        printf("A Transpose Expected: %f\n", expected[i]);
        assert(fabs(expected[i] - calculated[i]) < DELTA);
    }
    return 0;
}
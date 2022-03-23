#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 10
#define DELTA 0.1f

float naive_norm(float x[SIZE], int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += x[i] * x[i];
    }
    return sqrtf(sum);
}

float no_opt_naive_norm(float x[SIZE], int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += x[i] * x[i];
    }
    return sqrtf(sum);
}

int main() {
    float x[SIZE] = {1.0f};
    for (int i = 0; i < SIZE; i++) {
        if (i % 2 == 0) {
            x[i] = 1.0f;
        } else {
            x[i] = 0.0f;
        }
    }
    float calculated = naive_norm(x, SIZE);
    float expected = no_opt_naive_norm(x, SIZE);
    printf("Calculated of Naive L2 Norm: %f\n", calculated);
    printf("Expected of Naive L2 Norm: %f\n", expected);
    assert(fabs(expected - calculated) < DELTA);
    return 0;
}
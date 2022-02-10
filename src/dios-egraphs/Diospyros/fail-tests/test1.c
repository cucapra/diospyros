#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 2

float sgn(float v) { return (v > 0) - (v < 0); }

float no_opt_sgn(float v) { return (v > 0) - (v < 0); }

float naive_norm(float *x, int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += x[i] * x[i];
    }
    return sqrtf(sum);
}

float no_opt_naive_norm(float *x, int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += x[i] * x[i];
    }
    return sqrtf(sum);
}

void sample_test(float A[SIZE]) {
    for (int k = 0; k < SIZE - 1; k++) {
        int m = SIZE - k;

        float x[SIZE];
        for (int i = 0; i < m; i++) {
            x[i] = 0.0f;
        }
        float e[SIZE];
        for (int i = 0; i < m; i++) {
            e[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            x[i] = 1.0f;
            e[i] = 2.0f;
        }

        float alpha = -sgn(x[0]) * naive_norm(x, m);
        A[k] = alpha;
    }
}

void no_opt_sample_test(float A[SIZE]) {
    for (int k = 0; k < SIZE - 1; k++) {
        int m = SIZE - k;

        float x[SIZE];
        for (int i = 0; i < m; i++) {
            x[i] = 0.0f;
        }
        float e[SIZE];
        for (int i = 0; i < m; i++) {
            e[i] = 0.0f;
        }
        for (int i = 0; i < m; i++) {
            x[i] = 1.0f;
            e[i] = 2.0f;
        }

        float alpha = -no_opt_sgn(x[0]) * no_opt_naive_norm(x, m);
        A[k] = alpha;
    }
}

int main(void) {
    float A[SIZE] = {0};
    sample_test(A);
    float expectedA[SIZE] = {0};
    no_opt_sample_test(expectedA);
    for (int i = 0; i < SIZE; i++) {
        printf("A Output: %f\n", A[i]);
        printf("Expected A Output: %f\n", expectedA[i]);
    }
}
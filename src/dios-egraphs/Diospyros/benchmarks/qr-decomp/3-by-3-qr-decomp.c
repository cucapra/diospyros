#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "test-utils.h"

#define SIZE 3

float sgn(float v) __attribute__((always_inline));
float naive_norm(float *x, int m) __attribute__((always_inline));
void naive_fixed_transpose(float *a) __attribute__((always_inline));
void naive_fixed_matrix_multiply(float *a, float *b, float *c)
    __attribute__((always_inline));

float sgn(float v) { return (v > 0) - (v < 0); }

float naive_norm(float *x, int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += x[i] * x[i];
    }
    return sqrtf(sum);
}

// Naive with fixed size
void naive_fixed_transpose(float *a) {
    for (int i = 0; i < SIZE; i++) {
        for (int j = i + 1; j < SIZE; j++) {
            float tmp = a[i * SIZE + j];
            a[i * SIZE + j] = a[j * SIZE + i];
            a[j * SIZE + i] = tmp;
        }
    }
}

void naive_fixed_matrix_multiply(float *a, float *b, float *c) {
    for (int y = 0; y < SIZE; y++) {
        for (int x = 0; x < SIZE; x++) {
            c[SIZE * y + x] = 0.0f;
            for (int k = 0; k < SIZE; k++) {
                c[SIZE * y + x] += a[SIZE * y + k] * b[SIZE * k + x];
            }
        }
    }
}

void naive_fixed_qr_decomp(float *A, float *Q, float *R) {
    memcpy(R, A, sizeof(float) * SIZE * SIZE);

    // Build identity matrix of size SIZE * SIZE
    float *I = (float *)calloc(SIZE * SIZE, sizeof(float));
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            I[i * SIZE + j] = (i == j);
        }
    }

    // Householder
    for (int k = 0; k < SIZE - 1; k++) {
        int m = SIZE - k;

        float *x = (float *)calloc(m, sizeof(float));
        float *e = (float *)calloc(m, sizeof(float));
        for (int i = 0; i < m; i++) {
            int row = k + i;
            x[i] = R[row * SIZE + k];
            e[i] = I[row * SIZE + k];
        }

        float alpha = -sgn(x[0]) * naive_norm(x, m);

        float *u = (float *)calloc(m, sizeof(float));
        float *v = (float *)calloc(m, sizeof(float));
        for (int i = 0; i < m; i++) {
            u[i] = x[i] + alpha * e[i];
        }
        float norm_u = naive_norm(u, m);
        for (int i = 0; i < m; i++) {
            v[i] = u[i] / (norm_u + 0.00001f);
        }

        float *q_min = (float *)calloc(m * m, sizeof(float));
        for (int i = 0; i < m; i++) {
            for (int j = 0; j < m; j++) {
                float q_min_i = ((i == j) ? 1.0f : 0.0f) - 2 * v[i] * v[j];
                q_min[i * m + j] = q_min_i;
            }
        }

        float *q_t = (float *)calloc(SIZE * SIZE, sizeof(float));
        for (int i = 0; i < SIZE; i++) {
            for (int j = 0; j < SIZE; j++) {
                float q_t_i;
                if ((i < k) || (j < k)) {
                    q_t_i = (i == j) ? 1.0f : 0.0f;
                } else {
                    q_t_i = q_min[(i - k) * m + (j - k)];
                }
                q_t[i * SIZE + j] = q_t_i;
            }
        }

        if (k == 0) {
            memcpy(Q, q_t, sizeof(float) * SIZE * SIZE);  // Q = q_t
            naive_fixed_matrix_multiply(q_t, A, R);       // R = q_t * A
        } else {
            float *res = (float *)calloc(SIZE * SIZE, sizeof(float));
            naive_fixed_matrix_multiply(q_t, Q, res);  // R = q_t * A
            memcpy(Q, res, sizeof(float) * SIZE * SIZE);
            naive_fixed_matrix_multiply(q_t, R, res);  // R = q_t * A
            memcpy(R, res, sizeof(float) * SIZE * SIZE);
        }
        free(x);
        free(e);
        free(u);
        free(v);
        free(q_min);
        free(q_t);
    }
    naive_fixed_transpose(Q);
}

int main(void) __attribute__((optimize("no-unroll-loops"))) {
    // time_t t = time(NULL);
    // srand((unsigned)time(&t));

    float A[SIZE * SIZE] = {0.0f};
    for (int i = 0; i < SIZE * SIZE; i++) {
        A[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }

    float Q[SIZE * SIZE] = {0.0f};
    float expectedQ[SIZE * SIZE] = {0.0f};
    float R[SIZE * SIZE] = {0.0f};
    float expectedR[SIZE * SIZE] = {0.0f};

    // This stackoverflow post explains how to calculate walk clock time.
    // https://stackoverflow.com/questions/42046712/how-to-record-elaspsed-wall-time-in-c
    // https://stackoverflow.com/questions/13156031/measuring-time-in-c
    // https://stackoverflow.com/questions/10192903/time-in-milliseconds-in-c
    // start timer
    long start, end;
    struct timeval timecheck;

    gettimeofday(&timecheck, NULL);
    start = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;

// calculate up c_out
#pragma nounroll
    for (int i = 0; i < NITER; i++) {
        naive_fixed_qr_decomp(A, Q, R);
    }

    // end timer
    gettimeofday(&timecheck, NULL);
    end = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;

    // report difference in runtime
    double diff = difftime(end, start);
    FILE *fptr = fopen(FILE_PATH, "w");
    if (fptr == NULL) {
        printf("Could not open file");
        return 0;
    }
    fprintf(fptr, "%ld\n", (end - start));
    fclose(fptr);
    printf("%ld milliseconds elapsed over %d iterations total\n", (end - start),
           NITER);

    return 0;
}
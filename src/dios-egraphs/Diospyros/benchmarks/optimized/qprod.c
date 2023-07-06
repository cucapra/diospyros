#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#define SIZE 4

#define MAX_FLOAT 100.00f
#define DELTA 0.1f
#define NITER 1000000000

__attribute__((always_inline)) void naive_cross_product(float *lhs, float *rhs,
                                                        float *result) {
    result[0] = lhs[1] * rhs[2] - lhs[2] * rhs[1];
    result[1] = lhs[2] * rhs[0] - lhs[0] * rhs[2];
    result[2] = lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

/*
  Computes the point product
*/
__attribute__((always_inline)) void naive_point_product(float *q, float *p,
                                                        float *result) {
    float qvec[3] = {q[0], q[1], q[2]};
    float uv[3];
    naive_cross_product(qvec, p, uv);

    for (int i = 0; i < 3; i++) {
        uv[i] = uv[i] * 2;
    }
    float qxuv[3];
    naive_cross_product(qvec, uv, qxuv);

    for (int i = 0; i < 3; i++) {
        result[i] = p[i] + q[3] * uv[i] + qxuv[i];
    }
}

void naive_quaternion_product(float *a_q, float *a_t, float *b_q, float *b_t,
                              float *r_q, float *r_t) {
    r_q[3] =
        a_q[3] * b_q[3] - a_q[0] * b_q[0] - a_q[1] * b_q[1] - a_q[2] * b_q[2];
    r_q[0] =
        a_q[3] * b_q[0] + a_q[0] * b_q[3] + a_q[1] * b_q[2] - a_q[2] * b_q[1];
    r_q[1] =
        a_q[3] * b_q[1] + a_q[1] * b_q[3] + a_q[2] * b_q[0] - a_q[0] * b_q[2];
    r_q[2] =
        a_q[3] * b_q[2] + a_q[2] * b_q[3] + a_q[0] * b_q[1] - a_q[1] * b_q[0];

    naive_point_product(a_q, b_t, r_t);
    for (int i = 0; i < 3; i++) {
        r_t[i] += a_t[i];
    }
}

int main(void) {
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    float a_q[SIZE];
    for (int i = 0; i < SIZE; i++) {
        a_q[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float a_t[SIZE];
    for (int i = 0; i < SIZE; i++) {
        a_t[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float b_q[SIZE];
    for (int i = 0; i < SIZE; i++) {
        b_q[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float b_t[SIZE];
    for (int i = 0; i < SIZE; i++) {
        b_t[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float r_q[SIZE];
    for (int i = 0; i < SIZE; i++) {
        r_q[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float r_t[SIZE];
    for (int i = 0; i < SIZE; i++) {
        r_t[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float expectedq[SIZE];
    for (int i = 0; i < SIZE; i++) {
        expectedq[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float expectedt[SIZE];
    for (int i = 0; i < SIZE; i++) {
        expectedt[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }

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
    for (int i = 0; i < NITER; i++) {
        naive_quaternion_product(a_q, a_t, b_q, b_t, r_q, r_t);
    }

    // end timer
    gettimeofday(&timecheck, NULL);
    end = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;

    // report difference in runtime
    double diff = difftime(end, start);
    printf("%ld milliseconds elapsed over %d iterations total\n", (end - start),
           NITER);

    return 0;

    // expectedq[3] =
    //     a_q[3] * b_q[3] - a_q[0] * b_q[0] - a_q[1] * b_q[1] - a_q[2] *
    //     b_q[2];
    // expectedq[0] =
    //     a_q[3] * b_q[0] + a_q[0] * b_q[3] + a_q[1] * b_q[2] - a_q[2] *
    //     b_q[1];
    // expectedq[1] =
    //     a_q[3] * b_q[1] + a_q[1] * b_q[3] + a_q[2] * b_q[0] - a_q[0] *
    //     b_q[2];
    // expectedq[2] =
    //     a_q[3] * b_q[2] + a_q[2] * b_q[3] + a_q[0] * b_q[1] - a_q[1] *
    //     b_q[0];

    // naive_point_product(a_q, b_t, expectedt);
    // for (int i = 0; i < 3; i++) {
    //     expectedt[i] += a_t[i];
    // }
    // for (int i = 0; i < SIZE; i++) {
    //     printf("Calculated q: %f\n", r_q[i]);
    //     printf("Expected q: %f\n", expectedq[i]);
    //     assert(fabs(expectedq[i] - r_q[i]) < DELTA);
    // }
    // for (int i = 0; i < 3; i++) {
    //     printf("Calculated t: %f\n", r_t[i]);
    //     printf("Expected t: %f\n", expectedt[i]);
    //     assert(fabs(expectedt[i] - r_t[i]) < DELTA);
    // }
}
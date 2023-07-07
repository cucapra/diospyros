#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_FLOAT 100.00f
#define DELTA 0.1f

#define SIZE 4

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

// --- NO OPTS ---

__attribute__((always_inline)) void no_opt_naive_cross_product(float *lhs,
                                                               float *rhs,
                                                               float *result) {
    result[0] = lhs[1] * rhs[2] - lhs[2] * rhs[1];
    result[1] = lhs[2] * rhs[0] - lhs[0] * rhs[2];
    result[2] = lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

/*
  Computes the point product
*/
__attribute__((always_inline)) void no_opt_naive_point_product(float *q,
                                                               float *p,
                                                               float *result) {
    float qvec[3] = {q[0], q[1], q[2]};
    float uv[3];
    no_opt_naive_cross_product(qvec, p, uv);

    for (int i = 0; i < 3; i++) {
        uv[i] = uv[i] * 2;
    }
    float qxuv[3];
    no_opt_naive_cross_product(qvec, uv, qxuv);

    for (int i = 0; i < 3; i++) {
        result[i] = p[i] + q[3] * uv[i] + qxuv[i];
    }
}

void no_opt_naive_quaternion_product(float *a_q, float *a_t, float *b_q,
                                     float *b_t, float *r_q, float *r_t) {
    r_q[3] =
        a_q[3] * b_q[3] - a_q[0] * b_q[0] - a_q[1] * b_q[1] - a_q[2] * b_q[2];
    r_q[0] =
        a_q[3] * b_q[0] + a_q[0] * b_q[3] + a_q[1] * b_q[2] - a_q[2] * b_q[1];
    r_q[1] =
        a_q[3] * b_q[1] + a_q[1] * b_q[3] + a_q[2] * b_q[0] - a_q[0] * b_q[2];
    r_q[2] =
        a_q[3] * b_q[2] + a_q[2] * b_q[3] + a_q[0] * b_q[1] - a_q[1] * b_q[0];

    no_opt_naive_point_product(a_q, b_t, r_t);
    for (int i = 0; i < 3; i++) {
        r_t[i] += a_t[i];
    }
}

int main(void) {
    srand(1);  // set seed

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
        r_q[i] = 0.0f;
    }
    float r_t[SIZE];
    for (int i = 0; i < SIZE; i++) {
        r_t[i] = 0.0f;
    }
    float expectedq[SIZE];
    for (int i = 0; i < SIZE; i++) {
        expectedq[i] = 0.0f;
    }
    float expectedt[SIZE];
    for (int i = 0; i < SIZE; i++) {
        expectedt[i] = 0.0f;
    }
    naive_quaternion_product(a_q, a_t, b_q, b_t, r_q, r_t);
    no_opt_naive_quaternion_product(a_q, a_t, b_q, b_t, expectedq, expectedt);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", r_q[i]);
        assert(expectedq[i] == r_q[i]);
    }
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", r_t[i]);
        assert(expectedt[i] == r_t[i]);
    }
}
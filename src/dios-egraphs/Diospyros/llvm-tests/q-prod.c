#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

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

int main(void) {}
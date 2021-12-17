#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 4

#define MAX_FLOAT 100.00f
#define DELTA 0.1f

void cross_product(float lhs[3], float rhs[3], float result[3])
    __attribute__((always_inline));

void cross_product(float lhs[3], float rhs[3], float result[3]) {
    result[0] = lhs[1] * rhs[2] - lhs[2] * rhs[1];
    result[1] = lhs[2] * rhs[0] - lhs[0] * rhs[2];
    result[2] = lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

/*
  Computes the point product
*/
void point_product(float q_in[4], float p_in[4], float result_out[4]) {
    float qvec[3] = {q_in[0], q_in[1], q_in[2]};
    // qvec = {0, 1, 2}

    float uv[3];
    cross_product(qvec, p_in, uv);
    // uv = {1 * 2 - 2 * 1, 2 * 0 - 0 * 2, 0 * 1 - 1 * 0} = {0, 0, 0}

    for (int i = 0; i < 3; i++) {
        uv[i] = uv[i] * 2;
    }
    // uv = {0, 0 , 0}
    float qxuv[3];
    cross_product(qvec, uv, qxuv);
    // qxuv = {0, 0, 0}

    for (int i = 0; i < 3; i++) {
        result_out[i] = p_in[i] + q_in[3] * uv[i] + qxuv[i];
    }
}

int main(void) {
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    float q_in[SIZE];
    for (int i = 0; i < SIZE; i++) {
        q_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float p_in[SIZE];
    for (int i = 0; i < SIZE; i++) {
        p_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float result_out[SIZE];
    for (int i = 0; i < SIZE; i++) {
        result_out[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float expected[SIZE];
    for (int i = 0; i < SIZE; i++) {
        expected[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    point_product(q_in, p_in, result_out);
    float qvec[3] = {q_in[0], q_in[1], q_in[2]};
    // qvec = {0, 1, 2}

    float uv[3];
    cross_product(qvec, p_in, uv);
    // uv = {1 * 2 - 2 * 1, 2 * 0 - 0 * 2, 0 * 1 - 1 * 0} = {0, 0, 0}

    for (int i = 0; i < 3; i++) {
        uv[i] = uv[i] * 2;
    }
    // uv = {0, 0 , 0}
    float qxuv[3];
    cross_product(qvec, uv, qxuv);
    // qxuv = {0, 0, 0}

    for (int i = 0; i < 3; i++) {
        expected[i] = p_in[i] + q_in[3] * uv[i] + qxuv[i];
    }
    for (int i = 0; i < 4; i++) {
        printf("Calculated: %f\n", result_out[i]);
        printf("Expected: %f\n", expected[i]);
        assert(fabs(expected[i] - result_out[i]) < DELTA);
    }
}
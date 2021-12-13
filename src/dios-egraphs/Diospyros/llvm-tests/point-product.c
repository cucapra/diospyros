#include <assert.h>
#include <stdio.h>

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
    float q_in[4] = {0, 1, 2, 3};
    float p_in[4] = {0, 1, 2, 3};
    float result_out[4] = {0, 0, 0, 0};
    point_product(q_in, p_in, result_out);
    float expected[4] = {0, 1, 2, 0};
    for (int i = 0; i < 4; i++) {
        printf("%f\n", result_out[i]);
        assert(expected[i] == result_out[i]);
    }
}
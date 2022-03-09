#include <assert.h>
#include <math.h>
#include <stdio.h>
#define SIZE 8

void vsqrt(float a_in[SIZE], float b_out[SIZE], float c_out[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        b_out[i] = sqrtf(a_in[i]);
        c_out[i] = sqrtf(a_in[i]);
    }
}

int main(void) {
    float a_in[SIZE] = {9, 8, 7, 6, 5, 4, 3, 2};
    float b_out[SIZE] = {0, 0, 0, 0, 0, 0, 0, 0};
    float c_out[SIZE] = {0, 0, 0, 0, 0, 0, 0, 0};
    vsqrt(a_in, b_out, c_out);
    float delta = 0.00001f;
    float expected[SIZE] = {3.000000f, 2.828427f, 2.645751f, 2.449490f,
                            2.236068f, 2.000000f, 1.732051f, 1.414214f};
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", c_out[i]);
        assert(fabs(expected[i] - c_out[i]) < delta);
    }
    // 3.000000
    // 2.828427
    // 2.645751
    // 2.449490
    // 2.236068
    // 2.000000
    // 1.732051
    // 1.414214
}
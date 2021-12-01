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
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", b_out[i]);
        printf("%f\n", c_out[i]);
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
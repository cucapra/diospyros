#include <stdio.h>
#define SIZE 8

void continue_test(float a_in[SIZE], float scalar_in, float b_out[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        if (i < SIZE / 2) continue;
        b_out[i] = a_in[i] * scalar_in;
    }
}

int main(void) {
    float a_in[SIZE] = {9, 8, 7, 6, 5, 4, 3, 2};
    float scalar_in = 10;
    float b_out[SIZE] = {0, 0, 0, 0, 0, 0, 0, 0};
    continue_test(a_in, scalar_in, b_out);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", b_out[i]);
    }
    // 0.000000
    // 0.000000
    // 0.000000
    // 0.000000
    // 50.000000
    // 40.000000
    // 30.000000
    // 20.000000
    return 0;
}
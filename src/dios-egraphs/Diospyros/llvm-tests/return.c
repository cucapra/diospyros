#include <stdio.h>
#define SIZE 8

void return_test(float a_in[SIZE], float scalar_in, float b_out[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        if (i == SIZE / 2) return;
        b_out[i] = a_in[i] * scalar_in;
    }
    b_out[SIZE / 2] = a_in[SIZE / 2] * scalar_in;  // shouldn't run
}

int main(void) {
    float a_in[SIZE] = {9, 8, 7, 6, 5, 4, 3, 2};
    float scalar_in = 10;
    float b_out[SIZE] = {0, 0, 0, 0, 0, 0, 0, 0};
    return_test(a_in, scalar_in, b_out);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", b_out[i]);
    }
    // 90.000000
    // 80.000000
    // 70.000000
    // 60.000000
    // 0.000000
    // 0.000000
    // 0.000000
    // 0.000000
}
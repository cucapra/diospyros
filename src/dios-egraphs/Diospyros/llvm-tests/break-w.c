#include <stdio.h>
#define SIZE 8

void break_w_test(float a_in[SIZE], float scalar_in, float b_out[SIZE]) {
    int i = SIZE - 1;
    while (i >= 0) {
        if (i < SIZE / 2) break;
        b_out[i] = a_in[i] * scalar_in;
        i -= 1;
    }
    b_out[0] = scalar_in;
}

int main(void) {
    float a_in[SIZE] = {9, 8, 7, 6, 5, 4, 3, 2};
    float scalar_in = 10;
    float b_out[SIZE] = {0, 0, 0, 0, 0, 0, 0, 0};
    break_w_test(a_in, scalar_in, b_out);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", b_out[i]);
    }
    // 10.000000
    // 0.000000
    // 0.000000
    // 0.000000
    // 50.000000
    // 40.000000
    // 30.000000
    // 20.000000
    return 0;
}
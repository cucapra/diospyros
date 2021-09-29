#include <math.h>
#include <stdio.h>
#define SIZE 8

void cube(float a_in[SIZE], float b_out[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        b_out[i] = powf(a_in[i], 3);
    }
}
int main(void) {
    float a_in[SIZE] = {9, 8, 7, 6, 5, 4, 3, 2};
    float b_out[SIZE] = {0, 0, 0, 0, 0, 0, 0, 0};
    cube(a_in, b_out);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", b_out[i]);
    }
    // 729.000000
    // 512.000000
    // 343.000000
    // 216.000000
    // 125.000000
    // 64.000000
    // 27.000000
    // 8.000000
}

#include <assert.h>
#include <stdio.h>
#define SIZE 8

void matrix_multiply(float a_in[SIZE], float scalar_in, float b_out[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        b_out[i] = a_in[i] * scalar_in;
    }
}

int main(void) {
    float a_in[SIZE] = {1, 2, 3, 4, 5, 6, 7, 8};
    float scalar_in = 10;
    float b_in[SIZE] = {1, 2, 3, 4, 5, 6, 7, 8};
    matrix_multiply(a_in, scalar_in, b_in);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", b_in[i]);
    }
    assert(b_in[0] == 10);
    assert(b_in[1] == 20);
    assert(b_in[2] == 30);
    assert(b_in[3] == 40);
    assert(b_in[4] == 50);
    assert(b_in[5] == 60);
    assert(b_in[6] == 70);
    assert(b_in[7] == 80);
}

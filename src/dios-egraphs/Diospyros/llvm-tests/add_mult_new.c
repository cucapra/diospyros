#include <assert.h>
#include <stdio.h>
#define SIZE 4

void add_mult(float a_in[SIZE], float b_in[SIZE], float c_out[SIZE]) {
    c_out[0] = a_in[0] + b_in[0];
    c_out[1] = a_in[1] * b_in[1];
    c_out[2] = a_in[2] + b_in[2];
    c_out[3] = a_in[3] * b_in[3];
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4};
    float b_in[SIZE] = {2, 3, 4, 5};
    float c_out[SIZE];
    add_mult(a_in, b_in, c_out);
    assert(c_out[0] == 3);
    assert(c_out[1] == 6);
    assert(c_out[2] == 7);
    assert(c_out[3] == 20);
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    // expected:3, 6, 7, 20
    return 0;
}
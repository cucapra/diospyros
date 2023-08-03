#include <assert.h>
#include <stdio.h>
#define SIZE 4

void oo(float a_in[SIZE], float b_in[SIZE], float c_out[SIZE]) {
    c_out[0] = a_in[0] + b_in[0];
    c_out[3] = a_in[3] + b_in[3];
    c_out[2] = a_in[2] + b_in[2];
    c_out[1] = a_in[1] + b_in[1];
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4};
    float b_in[SIZE] = {5, 6, 7, 8};
    float c_out[SIZE];
    oo(a_in, b_in, c_out);
    assert(c_out[0] == 6);
    assert(c_out[1] == 8);
    assert(c_out[2] == 10);
    assert(c_out[3] == 12);
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    // 6, 8, 10, 12
    return 0;
}
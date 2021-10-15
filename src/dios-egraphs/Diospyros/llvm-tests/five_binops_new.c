#include <stdio.h>
#define SIZE 4

void add5(float a_in[SIZE], float b_in[SIZE], float c_in[SIZE],
          float d_in[SIZE], float e_in[SIZE], float c_out[SIZE]) {
    c_out[0] = a_in[0] + b_in[0] + c_in[0] + d_in[0] + e_in[0];
    c_out[1] = a_in[1] + b_in[1] + c_in[1] + d_in[1] + e_in[1];
    c_out[2] = a_in[2] + b_in[2] + c_in[2] + d_in[2] + e_in[2];
    c_out[3] = a_in[3] + b_in[3] + c_in[3] + d_in[3] + e_in[3];
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4};
    float b_in[SIZE] = {5, 6, 7, 8};
    float c_in[SIZE] = {1, 2, 3, 4};
    float d_in[SIZE] = {5, 6, 7, 8};
    float e_in[SIZE] = {1, 2, 3, 4};
    float c_out[SIZE];
    add5(a_in, b_in, c_in, d_in, e_in, c_out);
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    // expected: 13, 18, 23, 28
    return 0;
}

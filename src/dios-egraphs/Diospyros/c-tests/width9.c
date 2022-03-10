#include <assert.h>
#include <stdio.h>
#define SIZE 9

void sum(float a_in[SIZE], float b_in[SIZE], float c_out[SIZE]) {
    c_out[0] = a_in[0] + b_in[0];
    c_out[1] = a_in[1] + b_in[1];
    c_out[2] = a_in[2] + b_in[2];
    c_out[3] = a_in[3] + b_in[3];
    c_out[4] = a_in[4] + b_in[4];
    c_out[5] = a_in[5] + b_in[5];
    c_out[6] = a_in[6] + b_in[6];
    c_out[7] = a_in[7] + b_in[7];
    c_out[8] = a_in[8] + b_in[8];
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    float b_in[SIZE] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    float c_out[SIZE];
    sum(a_in, b_in, c_out);
    assert(c_out[0] == 2);
    assert(c_out[1] == 4);
    assert(c_out[2] == 6);
    assert(c_out[3] == 8);
    assert(c_out[4] == 10);
    assert(c_out[5] == 12);
    assert(c_out[6] == 14);
    assert(c_out[7] == 16);
    assert(c_out[8] == 18);
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    printf("fifth: %f\n", c_out[4]);
    printf("sixth: %f\n", c_out[5]);
    printf("seventh: %f\n", c_out[6]);
    printf("eight: %f\n", c_out[7]);
    printf("ninth: %f\n", c_out[8]);
    // expected: 2, 4, 6, 8, 10, 12, 14, 16, 18
    return 0;
}
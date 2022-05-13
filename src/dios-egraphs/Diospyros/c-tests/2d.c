#include <assert.h>
#include <stdio.h>
#define SIZE 4

void sum(float a_in[SIZE][SIZE], float b_in[SIZE], float c_out[SIZE]) {
    c_out[0] = a_in[0][3] + b_in[0];
    c_out[1] = a_in[1][3] + b_in[1];
    c_out[2] = a_in[2][3] + b_in[2];
    c_out[3] = a_in[3][3] + a_in[0][1];
}

int main(int argc, char **argv) {
    float a_in[SIZE][SIZE] = {
        {1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 14, 15, 16}};
    float b_in[SIZE] = {5, 6, 7, 8};
    float c_out[SIZE];
    sum(a_in, b_in, c_out);
    assert(c_out[0] == 9);
    assert(c_out[1] == 14);
    assert(c_out[2] == 19);
    assert(c_out[3] == 18);
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    // expected: 9, 14, 19, 18
    return 0;
}
#include <assert.h>
#include <stdio.h>

float a_in[4][4] = {
    {1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 14, 15, 16}};
float b_in[] = {5, 6, 7, 8};

int main(int argc, char **argv) {
    float c_out[4];
    c_out[0] = a_in[0][3] + b_in[0];
    c_out[1] = a_in[1][3] + b_in[1];
    c_out[2] = a_in[2][3] + b_in[2];
    c_out[3] = a_in[3][3] + a_in[0][1];
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    // expected: 9, 14, 19, 18
    return 0;
}
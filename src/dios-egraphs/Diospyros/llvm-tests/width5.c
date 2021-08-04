#include <stdio.h>

float a_in[] = {1, 2, 3, 4, 5};
float b_in[] = {6, 7, 8, 9, 10};

int main(int argc, char **argv) {
    float c_out[5];
    c_out[0] = a_in[0] + b_in[0];
    c_out[1] = a_in[1] + b_in[1];
    c_out[2] = a_in[2] + b_in[2];
    c_out[3] = a_in[3] + b_in[3];
    c_out[4] = a_in[4] + b_in[4];
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    printf("fifth: %f\n", c_out[4]);
    // expected: 7, 9, 11, 13, 15
    return 0;
}
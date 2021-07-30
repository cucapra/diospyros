#include <stdio.h>

float a_in[] = {1, 2, 3, 4};
float b_in[] = {2, 3, 4, 5};

int main(int argc, char **argv) {
    float d_out[4];
    d_out[0] = a_in[0] + b_in[0];
    d_out[1] = a_in[1] * b_in[1];
    d_out[2] = a_in[2] + b_in[2];
    d_out[3] = a_in[3] * b_in[3];
    printf("first: %f\n", d_out[0]);
    printf("second: %f\n", d_out[1]);
    printf("third: %f\n", d_out[2]);
    printf("fourth: %f\n", d_out[3]);
    return 0;
}
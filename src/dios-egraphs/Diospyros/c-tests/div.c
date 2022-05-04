#include <assert.h>
#include <stdio.h>
#include <math.h>
#define SIZE 4
#define DELTA 0.1

void sum(float a_in[SIZE], float b_in[SIZE], float c_out[SIZE]) {
    c_out[0] = b_in[0] / a_in[0];
    c_out[1] = b_in[1] / a_in[1];
    c_out[2] = b_in[2] / a_in[2];
    c_out[3] = b_in[3] / a_in[3];
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4};
    float b_in[SIZE] = {5, 6, 6, 8};
    float c_out[SIZE];
    sum(a_in, b_in, c_out);
    assert(fabs(c_out[0] - 5.0) < DELTA);
    assert(fabs(c_out[1] - 3.0) < DELTA);
    assert(fabs(c_out[2] - 2.0) < DELTA);
    assert(fabs(c_out[3] - 2.0) < DELTA);
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    return 0;
}
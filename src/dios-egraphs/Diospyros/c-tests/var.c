#include <assert.h>
#include <stdio.h>
#define SIZE 4

void sum(float a_in[SIZE], float b_in[SIZE], float c_out[SIZE]) {
    float t1 = 10;
    float t2 = 20;
    c_out[0] = a_in[0] + b_in[0];
    c_out[1] = t1 + b_in[1];
    c_out[2] = a_in[2] + t2;
    c_out[3] = t2 + t1;
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4};
    float b_in[SIZE] = {5, 6, 7, 8};
    float c_out[SIZE];
    sum(a_in, b_in, c_out);
    assert(c_out[0] == 6);
    assert(c_out[1] == 16);
    assert(c_out[2] == 23);
    assert(c_out[3] == 30);
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    // expected: 6, 16, 23, 30
    return 0;
}
#include <assert.h>
#include <stdio.h>
#define SIZE 4

void mac(float a_in[SIZE], float b_in[SIZE], float c_in[SIZE],
         float d_out[SIZE]) {
    d_out[0] = a_in[0] + (b_in[0] * c_in[0]);
    d_out[1] = a_in[1] + (b_in[1] * c_in[1]);
    d_out[2] = a_in[2] + (b_in[2] * c_in[2]);
    d_out[3] = a_in[3] + (b_in[3] * c_in[3]);
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4};
    float b_in[SIZE] = {2, 3, 4, 5};
    float c_in[SIZE] = {3, 4, 5, 6};
    float d_out[SIZE];
    mac(a_in, b_in, c_in, d_out);
    assert(d_out[0] == 7);
    assert(d_out[1] == 14);
    assert(d_out[2] == 23);
    assert(d_out[3] == 34);
    printf("first: %f\n", d_out[0]);
    printf("second: %f\n", d_out[1]);
    printf("third: %f\n", d_out[2]);
    printf("fourth: %f\n", d_out[3]);
    // expected: 7, 14, 23, 34
    return 0;
}
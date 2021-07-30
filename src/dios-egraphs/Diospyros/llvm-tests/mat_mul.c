#include <stdio.h>

float a_in[] = {1, 2, 3, 4};
float b_in[] = {5, 6, 7, 8};

int main(int argc, char **argv) {
    int c_out[4] = { a_in[0] * b_in[0] + a_in[1] * b_in[2],
                    a_in[0] * b_in[1] + a_in[1] * b_in[3],
                    a_in[2] * b_in[0] + a_in[3] * b_in[2],
                    a_in[2] * b_in[1] + a_in[3] * b_in[3]};
    printf("first: %d\n", c_out[0]);
    printf("second: %d\n", c_out[1]);
    printf("third: %d\n", c_out[2]);
    printf("fourth: %d\n", c_out[3]);
    return 0;
}
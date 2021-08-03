#include <stdio.h>

float a_in[] = {1, 2, 3, 4};
float b_in[] = {5, 6, 7, 8};
float t1 = 10;
float t2 = 20;

int main(int argc, char **argv) {
    //  return argc + 5;
    float c_out[4];
    c_out[0] = a_in[0] + b_in[0];
    c_out[1] = t1 + b_in[1];
    c_out[2] = a_in[2] + t2;
    c_out[3] = t2 + t1;
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    return 0;
}
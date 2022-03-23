#include <assert.h>
#include <stdio.h>
#define SIZE 8

void if_else(float a_in[SIZE], float b_out[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        if (i < SIZE / 2) {
            b_out[i] = a_in[i];
        } else {
            b_out[i] = a_in[i] + 1;
        }
    }
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4, 5, 6, 7, 8};
    float b_out[SIZE] = {0, 0, 0, 0, 0, 0, 0, 0};
    if_else(a_in, b_out);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", b_out[i]);
    }
    assert(b_out[0] == 1);
    assert(b_out[1] == 2);
    assert(b_out[2] == 3);
    assert(b_out[3] == 4);
    assert(b_out[4] == 6);
    assert(b_out[5] == 7);
    assert(b_out[6] == 8);
    assert(b_out[7] == 9);
    // expected: 1, 2, 3, 4, 6, 7, 8, 9
    return 0;
}
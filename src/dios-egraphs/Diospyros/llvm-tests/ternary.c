#include <assert.h>
#include <stdio.h>
#define SIZE 8

void tern(float a_in[SIZE], float b_out[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        b_out[i] = (i < SIZE / 2) ? a_in[i] : 0;
    }
}

int main(int argc, char **argv) {
    float a_in[SIZE] = {1, 2, 3, 4, 5, 6, 7, 8};
    float b_out[SIZE] = {5, 6, 7, 8, 1, 2, 3, 4};
    tern(a_in, b_out);
    for (int i = 0; i < SIZE; i++) {
        printf("%f\n", b_out[i]);
    }
    assert(b_out[0] == 1);
    assert(b_out[1] == 2);
    assert(b_out[2] == 3);
    assert(b_out[3] == 4);
    assert(b_out[4] == 0);
    assert(b_out[5] == 0);
    assert(b_out[6] == 0);
    assert(b_out[7] == 0);
    // 1.000000
    // 2.000000
    // 3.000000
    // 4.000000
    // 0.000000
    // 0.000000
    // 0.000000
    // 0.000000
    return 0;
}
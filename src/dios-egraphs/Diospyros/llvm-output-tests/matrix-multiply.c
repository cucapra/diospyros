#include <assert.h>
#include <stdio.h>

#define A_ROWS 2
#define A_COLS 2
#define B_COLS 2

void matrix_multiply(float a_in[A_ROWS * A_COLS], float b_in[A_COLS * B_COLS],
                     float c_out[A_ROWS * B_COLS]) {
    for (int y = 0; y < A_ROWS; y++) {
        for (int x = 0; x < B_COLS; x++) {
            c_out[B_COLS * y + x] = 0;
            for (int k = 0; k < A_COLS; k++) {
                c_out[B_COLS * y + x] +=
                    a_in[A_COLS * y + k] * b_in[B_COLS * k + x];
            }
        }
    }
}

int main(void) {
    float a_in[A_ROWS * A_COLS] = {1, 2, 3, 4};
    float b_in[A_COLS * B_COLS] = {1, 2, 3, 4};
    float c_out[A_ROWS * B_COLS] = {0, 0, 0, 0};
    matrix_multiply(a_in, b_in, c_out);
    printf("first: %f\n", c_out[0]);
    printf("second: %f\n", c_out[1]);
    printf("third: %f\n", c_out[2]);
    printf("fourth: %f\n", c_out[3]);
    assert(c_out[0] == 7);
    assert(c_out[1] == 10);
    assert(c_out[2] == 15);
    assert(c_out[3] == 22);
    // expected (7, 10, 15, 22)
    return 0;
}
#include <assert.h>
#include <stdio.h>

#define A_ROWS 3
#define A_COLS 3
#define B_COLS 3

void matrix_multiply(float a_in[A_ROWS][A_COLS], float b_in[A_COLS][B_COLS],
                     float c_out[A_ROWS][B_COLS]) {
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < B_COLS; j++) {
            float sum = 0.0;
            for (int k = 0; k < A_COLS; k++) {
                sum += a_in[i][k] * b_in[k][j];
            }
            c_out[i][j] = sum;
        }
    }
}

int main(void) {
    float a_in[A_ROWS][A_COLS] = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
    float b_in[A_COLS][B_COLS] = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
    float c_out[A_ROWS][B_COLS] = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
    matrix_multiply(a_in, b_in, c_out);
    float expected[A_ROWS][B_COLS] = {{30, 36, 42}, {66, 81, 96}, {102, 126, 150}};
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            printf("output: %f\n", c_out[i][j]);
            assert(expected[i][j] == c_out[i][j]);
        }
    }
    // output: 30.000000
    // output: 36.000000
    // output: 42.000000
    // output: 66.000000
    // output: 81.000000
    // output: 96.000000
    // output: 102.000000
    // output: 126.000000
    // output: 150.000000
    return 0;
}
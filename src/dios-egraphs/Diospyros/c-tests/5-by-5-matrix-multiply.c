#include <assert.h>
#include <stdio.h>

#define A_ROWS 5
#define A_COLS 5
#define B_COLS 5

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
    float a_in[A_ROWS][A_COLS] = {{1, 2, 3, 4, 5}, {6, 7, 8, 9, 10}, {1, 2, 3, 4, 5}, {6, 7, 8, 9, 10}, {1, 2, 3, 4, 5}};
    float b_in[A_COLS][B_COLS] = {{1, 2, 3, 4, 5}, {6, 7, 8, 9, 10}, {1, 2, 3, 4, 5}, {6, 7, 8, 9, 10}, {1, 2, 3, 4, 5}};
    float c_out[A_ROWS][B_COLS] = {{1, 2, 3, 4, 5}, {6, 7, 8, 9, 10}, {1, 2, 3, 4, 5}, {6, 7, 8, 9, 10}, {1, 2, 3, 4, 5}};
    matrix_multiply(a_in, b_in, c_out);
    float expected[A_ROWS][B_COLS] = {{45, 60, 75, 90, 105}, {120, 160, 200, 240, 280}, {45, 60, 75, 90, 105}, {120, 160, 200, 240, 280},{45, 60, 75, 90, 105}};
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            printf("output: %f\n", c_out[i][j]);
            assert(expected[i][j] == c_out[i][j]);
        }
    }
    // output: 45.000000
    // output: 60.000000
    // output: 75.000000
    // output: 90.000000
    // output: 105.000000
    // output: 120.000000
    // output: 160.000000
    // output: 200.000000
    // output: 240.000000
    // output: 280.000000
    // output: 45.000000
    // output: 60.000000
    // output: 75.000000
    // output: 90.000000
    // output: 105.000000
    // output: 120.000000
    // output: 160.000000
    // output: 200.000000
    // output: 240.000000
    // output: 280.000000
    // output: 45.000000
    // output: 60.000000
    // output: 75.000000
    // output: 90.000000
    // output: 105.000000
    return 0;
}
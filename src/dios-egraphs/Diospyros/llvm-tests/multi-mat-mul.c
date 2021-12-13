#include <assert.h>
#include <stdio.h>
#define ROWS 3
#define COLS 3

void matrix_multiply_3x3(float a[ROWS * COLS], float b[COLS * COLS],
                         float c[ROWS * COLS]) {
    for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
            c[j * ROWS + i] = 0;

            for (int k = 0; k < COLS; k++) {
                c[j * ROWS + i] += a[k * ROWS + i] * b[j * COLS + k];
            }
        }
    }
}

void multimatrix_multiply(float a_in[ROWS * COLS], float b_in[ROWS * COLS],
                          float c_in[ROWS * COLS], float d_out[ROWS * COLS]) {
    float ab[ROWS * COLS];
    matrix_multiply_3x3(a_in, b_in, ab);
    matrix_multiply_3x3(ab, c_in, d_out);
}

int main(void) {
    float a_in[ROWS * COLS] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    float b_in[ROWS * COLS] = {1, 0, 1, 0, 1, 0, 1, 0, 1};
    float c_in[ROWS * COLS] = {9, 8, 7, 6, 5, 4, 3, 2, 1};
    float d_out[ROWS * COLS] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
    multimatrix_multiply(a_in, b_in, c_in, d_out);
    float expected[ROWS * COLS] = {160, 200, 240, 100, 125, 150, 40, 50, 60};
    for (int i = 0; i < ROWS * COLS; i++) {
        printf("output: %f\n", d_out[i]);
        assert(expected[i] == d_out[i]);
    }
    // output: 160.000000
    // output: 200.000000
    // output: 240.000000
    // output: 100.000000
    // output: 125.000000
    // output: 150.000000
    // output: 40.000000
    // output: 50.000000
    // output: 60.000000
    return 0;
}
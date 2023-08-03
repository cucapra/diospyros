#include <assert.h>
#include <stdio.h>

#define A_ROWS 4
#define A_COLS 4
#define B_COLS 4

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

void no_opt_matrix_multiply(float a_in[A_ROWS][A_COLS],
                            float b_in[A_COLS][B_COLS],
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
    float a_in[A_ROWS][A_COLS] = {
        {1, 2, 3, 1}, {1, 2, 3, 1}, {4, 5, 6, 1}, {7, 8, 9, 1}};
    float b_in[A_COLS][B_COLS] = {
        {1, 2, 3, 1}, {1, 2, 3, 1}, {4, 5, 6, 1}, {7, 8, 9, 1}};
    float c_out[A_ROWS][B_COLS] = {
        {1, 2, 3, 1}, {1, 2, 3, 1}, {4, 5, 6, 1}, {7, 8, 9, 1}};
    float expected_c_out[A_ROWS][B_COLS] = {
        {1, 2, 3, 1}, {1, 2, 3, 1}, {4, 5, 6, 1}, {7, 8, 9, 1}};
    matrix_multiply(a_in, b_in, c_out);
    no_opt_matrix_multiply(a_in, b_in, expected_c_out);
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            printf("output: %f\n", c_out[i][j]);
            assert(expected_c_out[i][j] == c_out[i][j]);
        }
    }
    return 0;
}
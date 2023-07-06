#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_FLOAT 100.00f
#define DELTA 0.1f

#define A_ROWS 3
#define A_COLS 3
#define B_COLS 3

void matrix_multiply(float a_in[A_ROWS][A_COLS], float b,
                     float c_out[A_ROWS][B_COLS]) {
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < B_COLS; j++) {
            c_out[i][j] = a_in[i][j] * b;
        }
    }
}

void no_opt_matrix_multiply(float a_in[A_ROWS][A_COLS], float b,
                            float c_out[A_ROWS][B_COLS]) {
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < B_COLS; j++) {
            c_out[i][j] = a_in[i][j] * b;
        }
    }
}

int main(void) {
    srand(1);  // set seed

    float a_in[A_ROWS][A_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            a_in[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
    float b = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    float c_out[A_ROWS][A_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            c_out[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
    float expected[A_ROWS][A_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            expected[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }

    matrix_multiply(a_in, b, c_out);
    no_opt_matrix_multiply(a_in, b, expected);
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            printf("output: %f\n", c_out[i][j]);
            printf("expected: %f\n", expected[i][j]);
            assert(c_out[i][j] == expected[i][j]);
        }
    }
    return 0;
}
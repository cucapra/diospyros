#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_FLOAT 100.00f
#define DELTA 0.1f

#define A_ROWS 2
#define A_COLS 2
#define B_COLS 2

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
    srand(1);  // set seed

    float a_in[A_ROWS][A_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            a_in[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
    float b_in[A_ROWS][A_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            b_in[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
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

    matrix_multiply(a_in, b_in, c_out);
    no_opt_matrix_multiply(a_in, b_in, expected);
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            printf("output: %f\n", c_out[i][j]);
            printf("expected: %f\n", expected[i][j]);
            assert(c_out[i][j] == expected[i][j]);
        }
    }
    return 0;
}
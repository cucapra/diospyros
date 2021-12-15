#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define A_ROWS 50
#define A_COLS 50
#define B_COLS 50
#define MAX_FLOAT 100.00f
#define DELTA 0.1f

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
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    // load in a_in
    float a_in[A_ROWS][B_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            a_in[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
    // load in b_in
    float b_in[A_ROWS][B_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            b_in[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
    // set up c_out
    float c_out[A_ROWS][B_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            c_out[i][j] = 0.0f;
        }
    }
    // prep expected
    float expected[A_ROWS][B_COLS];
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            expected[i][j] = 0.0f;
        }
    }
    // calculate up c_out
    matrix_multiply(a_in, b_in, c_out);
    // calculate expected
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < B_COLS; j++) {
            float sum = 0.0;
            for (int k = 0; k < A_COLS; k++) {
                sum += a_in[i][k] * b_in[k][j];
            }
            expected[i][j] = sum;
        }
    }
    // check expected  ==  output
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < A_COLS; j++) {
            assert(fabs(expected[i][j] - c_out[i][j]) < DELTA);
        }
    }
    return 0;
}
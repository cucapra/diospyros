#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define A_ROWS 12
#define A_COLS 12
#define B_COLS 12
#define MAX_FLOAT 100.00f
#define DELTA 0.1f

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
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    // load in a_in
    float a_in[A_ROWS * A_COLS];
    for (int i = 0; i < A_ROWS * A_COLS; i++) {
        a_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // load in b_in
    float b_in[A_ROWS * B_COLS];
    for (int i = 0; i < A_ROWS * B_COLS; i++) {
        b_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // set up c_out
    float c_out[A_ROWS * B_COLS];
    for (int i = 0; i < A_ROWS * B_COLS; i++) {
        c_out[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // prep expected
    float expected[A_ROWS * B_COLS];
    for (int i = 0; i < A_ROWS * B_COLS; i++) {
        expected[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // calculate up c_out
    matrix_multiply(a_in, b_in, c_out);
    // calculate expected
    for (int y = 0; y < A_ROWS; y++) {
        for (int x = 0; x < B_COLS; x++) {
            expected[B_COLS * y + x] = 0;
            for (int k = 0; k < A_COLS; k++) {
                expected[B_COLS * y + x] +=
                    a_in[A_COLS * y + k] * b_in[B_COLS * k + x];
            }
        }
    }
    // check expected  ==  output
    for (int i = 0; i < A_ROWS * B_COLS; i++) {
        printf("calculated: %f\n", c_out[i]);
        printf("expected: %f\n", expected[i]);
        assert(fabs(expected[i] - c_out[i]) < DELTA);
    }
    return 0;
}
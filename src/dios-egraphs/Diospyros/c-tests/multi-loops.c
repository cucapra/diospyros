#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define ROWS 5

#define MAX_FLOAT 100.00f
#define DELTA 0.1f

void branching_loop(float a_in[ROWS], float b_in[ROWS], float c_in[ROWS],
                    float d_out[ROWS]) {
    for (int i = 0; i < ROWS; i++) {
        if (i % 3 == 0) {
            d_out[i] = a_in[i] * b_in[i];
        } else {
            d_out[i] = a_in[i] * c_in[i];
        }
    }
    for (int i = 0; i < ROWS; i++) {
        if (i % 5 == 0) {
            d_out[i] = a_in[i] - b_in[i];
        } else {
            d_out[i] = a_in[i] + c_in[i];
        }
    }
}

void no_opt_branching_loop(float a_in[ROWS], float b_in[ROWS], float c_in[ROWS],
                           float d_out[ROWS]) {
    for (int i = 0; i < ROWS; i++) {
        if (i % 3 == 0) {
            d_out[i] = a_in[i] * b_in[i];
        } else {
            d_out[i] = a_in[i] * c_in[i];
        }
    }
    for (int i = 0; i < ROWS; i++) {
        if (i % 5 == 0) {
            d_out[i] = a_in[i] - b_in[i];
        } else {
            d_out[i] = a_in[i] + c_in[i];
        }
    }
}

int main(void) {
    srand(1);  // set seed
    // load in a_in
    float a_in[ROWS];
    for (int i = 0; i < ROWS; i++) {
        a_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // load in b_in
    float b_in[ROWS];
    for (int i = 0; i < ROWS; i++) {
        b_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // load in c_in
    float c_in[ROWS];
    for (int i = 0; i < ROWS; i++) {
        c_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // set up c_out
    float d_out[ROWS];
    for (int i = 0; i < ROWS; i++) {
        d_out[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // prep expected
    float expected[ROWS];
    for (int i = 0; i < ROWS; i++) {
        expected[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }

    // calculate up c_out
    branching_loop(a_in, b_in, c_in, d_out);
    // calculate expected
    no_opt_branching_loop(a_in, b_in, c_in, expected);

    // check expected  ==  output
    for (int i = 0; i < ROWS; i++) {
        printf("calculated: %f\n", d_out[i]);
        printf("expected: %f\n", expected[i]);
        assert(fabs(expected[i] - d_out[i]) < DELTA);
    }
    return 0;
}
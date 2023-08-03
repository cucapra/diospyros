#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define ROW_SIZE 2
#define COL_SIZE 3
#define F_SIZE 1

#define MAX_FLOAT 100.00f
#define DELTA 0.1f

void stencil(float orig_in[ROW_SIZE * COL_SIZE],
             float sol_out[ROW_SIZE * COL_SIZE], float filter_in[F_SIZE]) {
    for (int r = 0; r < ROW_SIZE - 2; r++) {
        for (int c = 0; c < COL_SIZE - 2; c++) {
            float temp = 0;
            for (int k1 = 0; k1 < 2; k1++) {
                for (int k2 = 0; k2 < 2; k2++) {
                    temp += filter_in[k1 * 2 + k2] *
                            orig_in[(r + k1) * COL_SIZE + c + k2];
                }
            }
            sol_out[(r * COL_SIZE) + c] = temp;
        }
    }
}

void no_opt_stencil(float orig_in[ROW_SIZE * COL_SIZE],
                    float sol_out[ROW_SIZE * COL_SIZE],
                    float filter_in[F_SIZE]) {
    for (int r = 0; r < ROW_SIZE - 2; r++) {
        for (int c = 0; c < COL_SIZE - 2; c++) {
            float temp = 0;
            for (int k1 = 0; k1 < 2; k1++) {
                for (int k2 = 0; k2 < 2; k2++) {
                    temp += filter_in[k1 * 2 + k2] *
                            orig_in[(r + k1) * COL_SIZE + c + k2];
                }
            }
            sol_out[(r * COL_SIZE) + c] = temp;
        }
    }
}

int main(void) {
    srand(1);  // set seed

    float orig_in[ROW_SIZE * COL_SIZE];
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        orig_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float sol_out[ROW_SIZE * COL_SIZE];
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        sol_out[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float filter_in[F_SIZE];
    for (int i = 0; i < F_SIZE; i++) {
        filter_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float expected[ROW_SIZE * COL_SIZE];
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        expected[i] = sol_out[i];
    }
    stencil(orig_in, sol_out, filter_in);
    no_opt_stencil(orig_in, expected, filter_in);
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        printf("%f\n", sol_out[i]);
        printf("%f\n", expected[i]);
        assert(expected[i] == sol_out[i]);
    }
    return 0;
}
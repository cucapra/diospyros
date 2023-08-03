#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_FLOAT 100.00f
#define DELTA 0.1f

#define I_ROWS 2
#define I_COLS 2
#define F_ROWS 2
#define F_COLS 2
#define O_ROWS ((I_ROWS + F_ROWS) - 1)
#define O_COLS ((I_COLS + F_COLS) - 1)

void convolution(float mat_in[I_ROWS * I_COLS], float f_in[F_ROWS * F_COLS],
                 float mat_out[O_ROWS * O_COLS]) {
    for (int outRow = 0; outRow < O_ROWS; outRow++) {
        for (int outCol = 0; outCol < O_COLS; outCol++) {
            for (int fRow = 0; fRow < F_ROWS; fRow++) {
                for (int fCol = 0; fCol < F_COLS; fCol++) {
                    int fRowTrans = F_ROWS - 1 - fRow;
                    int fColTrans = F_COLS - 1 - fCol;
                    int iRow = outRow - fRowTrans;
                    int iCol = outCol - fColTrans;

                    if (iRow >= 0 && iRow < I_ROWS && iCol >= 0 &&
                        iCol < I_COLS) {
                        float v = mat_in[iRow * I_COLS + iCol] *
                                  f_in[fRowTrans * F_COLS + fColTrans];
                        mat_out[outRow * O_COLS + outCol] += v;
                    }
                }
            }
        }
    }
}

void no_opt_convolution(float mat_in[I_ROWS * I_COLS],
                        float f_in[F_ROWS * F_COLS],
                        float mat_out[O_ROWS * O_COLS]) {
    for (int outRow = 0; outRow < O_ROWS; outRow++) {
        for (int outCol = 0; outCol < O_COLS; outCol++) {
            for (int fRow = 0; fRow < F_ROWS; fRow++) {
                for (int fCol = 0; fCol < F_COLS; fCol++) {
                    int fRowTrans = F_ROWS - 1 - fRow;
                    int fColTrans = F_COLS - 1 - fCol;
                    int iRow = outRow - fRowTrans;
                    int iCol = outCol - fColTrans;

                    if (iRow >= 0 && iRow < I_ROWS && iCol >= 0 &&
                        iCol < I_COLS) {
                        float v = mat_in[iRow * I_COLS + iCol] *
                                  f_in[fRowTrans * F_COLS + fColTrans];
                        mat_out[outRow * O_COLS + outCol] += v;
                    }
                }
            }
        }
    }
}

int main(void) {
    srand(1);  // set seed

    float mat_in[I_ROWS * I_COLS];
    for (int i = 0; i < I_ROWS * I_COLS; i++) {
        mat_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float f_in[F_ROWS * F_COLS];
    for (int i = 0; i < F_ROWS * F_COLS; i++) {
        f_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float mat_out[O_ROWS * O_COLS];
    for (int i = 0; i < O_ROWS * O_COLS; i++) {
        mat_out[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float expected[O_ROWS * O_COLS];
    for (int i = 0; i < O_ROWS * O_COLS; i++) {
        expected[i] = mat_out[i];
    }

    convolution(mat_in, f_in, mat_out);
    no_opt_convolution(mat_in, f_in, expected);
    for (int i = 0; i < O_ROWS * O_COLS; i++) {
        printf("output: %f\n", mat_out[i]);
        printf("expected: %f\n", expected[i]);
        assert(mat_out[i] == expected[i]);
    }
    return 0;
}
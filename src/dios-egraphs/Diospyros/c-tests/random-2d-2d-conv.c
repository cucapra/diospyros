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

void convolution(float mat_in[restrict I_ROWS][I_COLS],
                 float f_in[restrict F_ROWS][F_COLS],
                 float mat_out[restrict O_ROWS][O_COLS]) {
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
                        float v =
                            mat_in[iRow][iCol] * f_in[fRowTrans][fColTrans];
                        mat_out[outRow][outCol] += v;
                    }
                }
            }
        }
    }
}

void no_opt_convolution(float mat_in[restrict I_ROWS][I_COLS],
                        float f_in[restrict F_ROWS][F_COLS],
                        float mat_out[restrict O_ROWS][O_COLS]) {
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
                        float v =
                            mat_in[iRow][iCol] * f_in[fRowTrans][fColTrans];
                        mat_out[outRow][outCol] += v;
                    }
                }
            }
        }
    }
}

int main(void) {
    srand(1);  // set seed

    float mat_in[I_ROWS][I_COLS];
    for (int i = 0; i < I_ROWS; i++) {
        for (int j = 0; j < I_COLS; j++) {
            mat_in[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
    float f_in[F_ROWS][F_COLS];
    for (int i = 0; i < F_ROWS; i++) {
        for (int j = 0; j < F_COLS; j++) {
            f_in[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
    float mat_out[O_ROWS][O_COLS];
    for (int i = 0; i < O_COLS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            mat_out[i][j] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
        }
    }
    float expected[O_ROWS][O_COLS];
    for (int i = 0; i < O_COLS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            expected[i][j] = mat_out[i][j];
        }
    }

    convolution(mat_in, f_in, mat_out);
    no_opt_convolution(mat_in, f_in, expected);
    for (int i = 0; i < O_ROWS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            printf("output: %f\n", mat_out[i][j]);
            printf("expected: %f\n", expected[i][j]);
            assert(mat_out[i][j] == expected[i][j]);
        }
    }
    return 0;
}
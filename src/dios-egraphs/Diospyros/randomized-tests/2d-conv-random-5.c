#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define I_ROWS 5
#define I_COLS 5
#define F_ROWS 3
#define F_COLS 3
#define O_ROWS ((I_ROWS + F_ROWS) - 1)
#define O_COLS ((I_COLS + F_COLS) - 1)
#define MAX_FLOAT 100.00f
#define DELTA 0.1f

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

int main(void) {
    time_t t = time(NULL);
    srand((unsigned)time(&t));
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
        mat_out[i] = 0;
    }
    float expected[O_ROWS * O_COLS];
    for (int i = 0; i < O_ROWS * O_COLS; i++) {
        expected[i] = 0;
    }
    convolution(mat_in, f_in, mat_out);
    // calculate expected
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
                        expected[outRow * O_COLS + outCol] += v;
                    }
                }
            }
        }
    }
    for (int i = 0; i < O_ROWS * O_COLS; i++) {
        printf("--------------------------\n");
        printf("calculated: %f\n", mat_out[i]);
        printf("expected: %f\n", expected[i]);
        printf("difference: %f\n", expected[i] - mat_out[i]);
    }
    for (int i = 0; i < O_ROWS * O_COLS; i++) {
        assert(fabs(expected[i] - mat_out[i]) < DELTA);
    }
    return 0;
}
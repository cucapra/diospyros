#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define I_ROWS 10
#define I_COLS 10
#define F_ROWS 5
#define F_COLS 5
#define O_ROWS ((I_ROWS + F_ROWS) - 1)
#define O_COLS ((I_COLS + F_COLS) - 1)
#define MAX_FLOAT 100.00f
#define DELTA 0.1f

void convolution(float mat_in[I_ROWS][I_COLS], float f_in[F_ROWS][F_COLS],
                 float mat_out[O_ROWS][O_COLS]) {
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
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    float mat_in[I_ROWS][I_COLS];
    for (int i = 0; i < I_ROWS; i++) {
        for (int j = 0; j < I_ROWS; j++) {
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
    for (int i = 0; i < O_ROWS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            mat_out[i][j] = 0;
        }
    }
    float expected[O_ROWS][O_COLS];
    for (int i = 0; i < O_ROWS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            expected[i][j] = 0;
        }
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
                        float v =
                            mat_in[iRow][iCol] * f_in[fRowTrans][fColTrans];
                        expected[outRow][outCol] += v;
                    }
                }
            }
        }
    }
    for (int i = 0; i < O_ROWS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            printf("calculated: %f\n", mat_out[i][j]);
            printf("expected: %f\n", expected[i][j]);
            assert(fabs(expected[i][j] - mat_out[i][j]) < DELTA);
        }
    }
    return 0;
}
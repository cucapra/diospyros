#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#include "test-utils.h"

#define I_ROWS 6
#define I_COLS 6
#define F_ROWS 4
#define F_COLS 4
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
        mat_out[i] = 0.0f;
    }
    float expected[O_ROWS * O_COLS];
    for (int i = 0; i < O_ROWS * O_COLS; i++) {
        expected[i] = mat_out[i];
    }

    // This stackoverflow post explains how to calculate walk clock time.
    // https://stackoverflow.com/questions/42046712/how-to-record-elaspsed-wall-time-in-c
    // https://stackoverflow.com/questions/13156031/measuring-time-in-c
    // https://stackoverflow.com/questions/10192903/time-in-milliseconds-in-c
    // start timer
    long start, end;
    struct timeval timecheck;

    gettimeofday(&timecheck, NULL);
    start = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;

    // calculate up c_out
    for (int i = 0; i < NITER; i++) {
        convolution(mat_in, f_in, mat_out);
    }

    // end timer
    gettimeofday(&timecheck, NULL);
    end = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;

    // report difference in runtime
    double diff = difftime(end, start);

    FILE *fptr = fopen(FILE_PATH, "w");
    if (fptr == NULL) {
        printf("Could not open file");
        return 0;
    }
    fprintf(fptr, "%ld\n", (end - start));
    fclose(fptr);

    printf("%ld milliseconds elapsed over %d iterations total\n", (end - start),
           NITER);
    return 0;
}
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#define ROW_SIZE 15
#define COL_SIZE 16
#define F_SIZE 9

#define MAX_FLOAT 100.00f
#define DELTA 0.1f
#define NITER 1000000000

void stencil(float orig_in[ROW_SIZE * COL_SIZE],
             float sol_out[ROW_SIZE * COL_SIZE], float filter_in[F_SIZE]) {
    for (int r = 0; r < ROW_SIZE - 2; r++) {
        for (int c = 0; c < COL_SIZE - 2; c++) {
            float temp = 0;
            for (int k1 = 0; k1 < 3; k1++) {
                for (int k2 = 0; k2 < 3; k2++) {
                    temp += filter_in[k1 * 3 + k2] *
                            orig_in[(r + k1) * COL_SIZE + c + k2];
                }
            }
            sol_out[(r * COL_SIZE) + c] = temp;
        }
    }
}

int main(void) {
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    float orig_in[ROW_SIZE * COL_SIZE];
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        orig_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float sol_out[ROW_SIZE * COL_SIZE];
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        sol_out[i] = 1;
    }
    float filter_in[F_SIZE];
    for (int i = 0; i < F_SIZE; i++) {
        filter_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float expected[ROW_SIZE * COL_SIZE];
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        expected[i] = 1;
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
        stencil(orig_in, sol_out, filter_in);
    }

    // end timer
    gettimeofday(&timecheck, NULL);
    end = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;

    // report difference in runtime
    double diff = difftime(end, start);
    printf("%ld milliseconds elapsed over %d iterations total\n", (end - start),
           NITER);

    return 0;

    stencil(orig_in, sol_out, filter_in);
    for (int r = 0; r < ROW_SIZE - 2; r++) {
        for (int c = 0; c < COL_SIZE - 2; c++) {
            float temp = 0;
            for (int k1 = 0; k1 < 3; k1++) {
                for (int k2 = 0; k2 < 3; k2++) {
                    temp += filter_in[k1 * 3 + k2] *
                            orig_in[(r + k1) * COL_SIZE + c + k2];
                }
            }
            expected[(r * COL_SIZE) + c] = temp;
        }
    }
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        printf("calculated: %f\n", sol_out[i]);
        printf("expected: %f\n", expected[i]);
        printf("difference: %f\n", expected[i] - sol_out[i]);
    }
    for (int i = 0; i < ROW_SIZE * COL_SIZE; i++) {
        assert(fabs(expected[i] - sol_out[i]) < DELTA);
    }
    return 0;
}
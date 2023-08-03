#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#include "test-utils.h"

#define A_ROWS 12
#define A_COLS 12
#define B_COLS 12

void matrix_multiply(float a_in[restrict A_ROWS * A_COLS],
                     float b_in[restrict A_COLS * B_COLS],
                     float c_out[restrict A_ROWS * B_COLS]) {
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
        matrix_multiply(a_in, b_in, c_out);
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
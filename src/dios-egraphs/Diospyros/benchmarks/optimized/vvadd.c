#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>

#define A_ROWS 12
#define MAX_FLOAT 100.00f
#define DELTA 0.1f
#define NITER 1000000000

void vvadd(float a_in[restrict A_ROWS], float b_in[restrict A_ROWS],
           float c_out[restrict A_ROWS]) {
    for (int i = 0; i < A_ROWS; i++) {
        c_out[i] = a_in[i] + b_in[i];
    }
}

int main(void) {
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    // load in a_in
    float a_in[A_ROWS];
    for (int i = 0; i < A_ROWS; i++) {
        a_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // load in b_in
    float b_in[A_ROWS];
    for (int i = 0; i < A_ROWS; i++) {
        b_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // set up c_out
    float c_out[A_ROWS];
    for (int i = 0; i < A_ROWS; i++) {
        c_out[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
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
        vvadd(a_in, b_in, c_out);
    }

    // end timer
    gettimeofday(&timecheck, NULL);
    end = (long)timecheck.tv_sec * 1000 + (long)timecheck.tv_usec / 1000;

    // report difference in runtime
    double diff = difftime(end, start);
    printf("%ld milliseconds elapsed over %d iterations total\n", (end - start),
           NITER);

    return 0;
}
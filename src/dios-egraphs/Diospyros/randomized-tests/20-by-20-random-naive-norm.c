#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 20
#define MAX_FLOAT 100.00f
#define DELTA 0.1f

float naive_norm(float x[SIZE], int m) {
    float sum = 0;
    for (int i = 0; i < m; i++) {
        sum += x[i] * x[i];
    }
    return sqrtf(sum);
}

int main(void) {
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    // load in a_in
    float x_in[SIZE];
    for (int i = 0; i < SIZE; i++) {
        x_in[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    // calculate up c_out
    float calculated = naive_norm(x_in, SIZE);
    // calculate expected
    float sum = 0;
    for (int i = 0; i < SIZE; i++) {
        sum += x_in[i] * x_in[i];
    }
    float expected = sqrtf(sum);
    // check expected  ==  output
    printf("calculated: %f\n", calculated);
    printf("expected: %f\n", expected);
    assert(fabs(expected - calculated) < DELTA);

    return 0;
}
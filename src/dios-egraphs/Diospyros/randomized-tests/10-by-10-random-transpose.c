#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define SIZE 10
#define MAX_FLOAT 100.00f
#define DELTA 0.1f

void naive_transpose(float a[SIZE * SIZE], int n) {
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            float tmp = a[i * n + j];
            a[i * n + j] = a[j * n + i];
            a[j * n + i] = tmp;
        }
    }
}
int main(void) {
    time_t t = time(NULL);
    srand((unsigned)time(&t));
    // load in a_in
    float x_calculated[SIZE * SIZE];
    for (int i = 0; i < SIZE * SIZE; i++) {
        x_calculated[i] = (float)rand() / (float)(RAND_MAX / MAX_FLOAT);
    }
    float x_expected[SIZE * SIZE] = {0.0f};
    for (int i = 0; i < SIZE * SIZE; i++) {
        x_expected[i] = x_calculated[i];
    }
    // calculate up c_out
    naive_transpose(x_calculated, SIZE);
    // calculate expected
    int n = SIZE;
    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            float tmp = x_expected[i * n + j];
            x_expected[i * n + j] = x_expected[j * n + i];
            x_expected[j * n + i] = tmp;
        }
    }
    // check expected  ==  output
    for (int i = 0; i < SIZE * SIZE; i++) {
        printf("calculated: %f\n", x_calculated[i]);
        printf("expected: %f\n", x_expected[i]);
        assert(fabs(x_expected[i] - x_calculated[i]) < DELTA);
    }

    return 0;
}
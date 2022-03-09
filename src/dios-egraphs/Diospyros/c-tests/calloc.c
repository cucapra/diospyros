#include <assert.h>
#include <stdio.h>
#define SIZE 4

void calloc_func(int m, float q_out[SIZE][SIZE]) {
    float *q_min = (float *)calloc(sizeof(float), m * m);
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < m; j++) {
            q_min[i * m + j] = 10.0f;
        }
    }
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            q_out[i][j] = q_min[i * m + j];
        }
    }
}

int main(int argc, char **argv) {
    float q_out[SIZE][SIZE] = {
        {1, 2, 3, 4}, {5, 6, 7, 8}, {9, 10, 11, 12}, {13, 14, 15, 16}};
    calloc_func(SIZE, q_out);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            printf("q_out: %f\n", q_out[i][j]);
            assert(q_out[i][j] == 10);
        }
    }
    return 0;
}
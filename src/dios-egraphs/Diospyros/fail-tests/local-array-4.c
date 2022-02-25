#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 2

void test(float A[SIZE]) {
    for (int i = 0; i < SIZE; i++) {
        float x[SIZE] = {0.0f};
        for (int j = 0; j < SIZE; j++) {
            x[j] = 1.0f;
        }
        float sum = 0.0f;
        for (int j = 0; j < SIZE; j++) {
            sum += x[j];
        }
        A[i] = sum;
    }
}

int main() {
    float A[SIZE] = {0.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] = (float)i;
    }
    test(A);
    for (int i = 0; i < SIZE; i++) {
        printf("A Output: %f\n", A[i]);
    }
    return 0;
}

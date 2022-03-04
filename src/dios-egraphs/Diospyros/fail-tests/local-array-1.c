#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SIZE 10

void test(float A[SIZE]) {
    float x[SIZE] = {[0 ... SIZE - 1] = 3.0f};
    for (int i = 0; i < SIZE; i++) {
        A[i] = x[i];
    }
}

int main() {
    float A[SIZE] = {[0 ... SIZE - 1] = 1.0f};
    test(A);
    for (int i = 0; i < SIZE; i++) {
        printf("A Output: %f\n", A[i]);
    }
    return 0;
}

#include <stdio.h>

#define A_ROWS 2
#define A_COLS 2
#define B_COLS 2

void matrix_multiply(float a_in[A_ROWS][A_COLS], float b_in[A_COLS][B_COLS],
                     float c_out[A_ROWS][B_COLS]) {
    for (int i = 0; i < A_ROWS; i++) {
        for (int j = 0; j < B_COLS; j++) {
            float sum = 0.0;
            for (int k = 0; k < A_COLS; k++) {
                sum += a_in[i][k] * b_in[k][j];
            }
            c_out[i][j] = sum;
        }
    }
}

int main(void) {
    float a_in[A_ROWS][A_COLS] = {{1, 2}, {3, 4}};
    float b_in[A_COLS][B_COLS] = {{1, 2}, {3, 4}};
    float c_out[A_ROWS][B_COLS] = {{0, 0}, {0, 0}};
    matrix_multiply(a_in, b_in, c_out);
    printf("first: %f\n", c_out[0][0]);
    printf("second: %f\n", c_out[0][1]);
    printf("third: %f\n", c_out[1][0]);
    printf("fourth: %f\n", c_out[1][1]);
    // expected (7, 10, 15, 22)
    return 0;
}
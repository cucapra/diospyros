#include <stdio.h>
#include <assert.h>

#define I_ROWS 2
#define I_COLS 2
#define F_ROWS 2
#define F_COLS 2
#define O_ROWS ((I_ROWS + F_ROWS) - 1)
#define O_COLS ((I_COLS + F_COLS) - 1)

void load_use_twice(float mat_in[I_ROWS][I_COLS], float f_in[F_ROWS][F_COLS],
                    float mat_out[O_ROWS][O_COLS],
                    float mat_out2[O_ROWS][O_COLS]) {
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
                        float v =
                            mat_in[iRow][iCol] * f_in[fRowTrans][fColTrans];
                        mat_out[outRow][outCol] +=
                            3 * v -
                            4;  // try something to use v in a different way
                        mat_out2[outRow][outCol] +=
                            2 * v +
                            1;  // try something to use v in a different way
                    }
                }
            }
        }
    }
}

int main(void) {
    float mat_in[I_ROWS][I_COLS] = {{1, 2}, {3, 4}};
    float f_in[F_ROWS][F_COLS] = {{1, 1}, {1, 1}};
    float mat_out1[O_ROWS][O_COLS] = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
    float mat_out2[O_ROWS][O_COLS] = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
    load_use_twice(mat_in, f_in, mat_out1, mat_out2);
    for (int i = 0; i < O_ROWS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            printf("output: %f\n", mat_out1[i][j]);
            printf("output: %f\n", mat_out2[i][j]);
        }
    }
    float output1[O_ROWS][O_COLS] = {{-1, 1, 2}, {4, 14, 10}, {5, 13, 8}};
    float output2[O_ROWS][O_COLS] = {{3, 8, 5}, {10, 24, 14}, {7, 16, 9}};
    for (int i = 0; i < O_ROWS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            assert(output1[i][j] == mat_out1[i][j]);
            assert(output2[i][j] == mat_out2[i][j]);
        }
    }
// output: -1.000000
// output: 3.000000
// output: 1.000000
// output: 8.000000
// output: 2.000000
// output: 5.000000

// output: 4.000000
// output: 10.000000
// output: 14.000000
// output: 24.000000
// output: 10.000000
// output: 14.000000

// output: 5.000000
// output: 7.000000
// output: 13.000000
// output: 16.000000
// output: 8.000000
// output: 9.000000
    return 0;
}
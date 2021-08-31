#include <stdio.h>

#define I_ROWS 2
#define I_COLS 2
#define F_ROWS 2
#define F_COLS 2
#define O_ROWS ((I_ROWS + F_ROWS) - 1)
#define O_COLS ((I_COLS + F_COLS) - 1)

void convolution(float mat_in[I_ROWS][I_COLS], float f_in[F_ROWS][F_COLS],
                 float mat_out[O_ROWS][O_COLS]) {
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
                        mat_out[outRow][outCol] += v;
                        // mat_out[outRow][outCol] +=
                        //     mat_in[iRow][iCol] * f_in[fRowTrans][fColTrans];
                    }
                }
            }
        }
    }
}

int main(void) {
    float mat_in[I_ROWS][I_COLS] = {{1, 2}, {3, 4}};
    float f_in[F_ROWS][F_COLS] = {{1, 1}, {1, 1}};
    float mat_out[O_ROWS][O_COLS] = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
    convolution(mat_in, f_in, mat_out);
    for (int i = 0; i < O_ROWS; i++) {
        for (int j = 0; j < O_COLS; j++) {
            printf("output: %f\n", mat_out[i][j]);
        }
    }
    // output: 1.000000
    // output: 3.000000
    // output: 2.000000
    // output: 4.000000
    // output: 10.000000
    // output: 6.000000
    // output: 3.000000
    // output: 7.000000
    // output: 4.000000
    return 0;
}
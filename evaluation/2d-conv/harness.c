#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#include "../../../diospyros-private/src/utils.h"

#define O_ROWS (I_ROWS + F_ROWS - 1)
#define O_COLS (I_COLS + F_COLS - 1)

float i[I_ROWS * I_COLS] __attribute__((section(".dram0.data")));
float f[F_ROWS * F_COLS] __attribute__((section(".dram0.data")));
float o[O_ROWS * O_COLS] __attribute__((section(".dram0.data")));

// Diospyros kernel
void kernel(float * input_I, float * input_F, float * input_O);

// Naive kernel
void naive_convolution(float *in, float *f, float *o,
                       int iRows, int iCols, int fRows, int fCols) {
  int outRows = (iRows + fRows) - 1;
  int outCols = (iCols + fCols) - 1;

  for (int outRow = 0; outRow < outRows; outRow++) {
    for (int outCol = 0; outCol < outCols; outCol++) {
      for (int fRow = 0; fRow < fRows; fRow++) {
        for (int fCol = 0; fCol < fCols; fCol++) {
          int fRowTrans = fRows - 1 - fRow;
          int fColTrans = fCols - 1 - fCol;
          int iRow = outRow - fRowTrans;
          int iCol = outCol -fColTrans;

          if (iRow >= 0 && iRow < iRows && iCol >= 0 && iCol < iCols) {
            float v = in[iRow*iCols + iCol] * f[fRowTrans*fCols + fColTrans];
            o[outRow*outCols + outCol] += v;
          }
        }
      }
    }
  }
}

// Naive kernel, hard-coded size
void naive_convolution_hard_size(float *in, float *f, float *o) {
  int outRows = (I_ROWS + F_ROWS) - 1;
  int outCols = (I_COLS + F_COLS) - 1;

  for (int outRow = 0; outRow < outRows; outRow++) {
    for (int outCol = 0; outCol < outCols; outCol++) {
      for (int fRow = 0; fRow < F_ROWS; fRow++) {
        for (int fCol = 0; fCol < F_COLS; fCol++) {
          int fRowTrans = F_ROWS - 1 - fRow;
          int fColTrans = F_COLS - 1 - fCol;
          int iRow = outRow - fRowTrans;
          int iCol = outCol -fColTrans;

          if (iRow >= 0 && iRow < I_ROWS && iCol >= 0 && iCol < I_COLS) {
            float v = in[iRow*I_COLS + iCol] * f[fRowTrans*F_COLS + fColTrans];
            o[outRow*outCols + outCol] += v;
          }
        }
      }
    }
  }
}

// Nature kernel
void conv2df(const float32_t *x, int M, int N,
            const float32_t *y, int P, int Q, float32_t * z);

int main(int argc, char **argv) {

  FILE *file = fopen(OUTFILE, "w");
  if (file == NULL) return -1;
  fprintf(file, "kernel,I_ROWS,I_COLS,F_ROWS,F_COLS,cycles\n");

  init_rand(10);

  create_random_mat(i, I_ROWS, I_COLS);
  create_random_mat(f, F_ROWS, F_COLS);
  zero_matrix(o, O_ROWS, O_COLS);

  print_matrix(i, I_ROWS, I_COLS);
  print_matrix(f, F_ROWS, F_COLS);

  // Run naive once to warm cache
  naive_convolution(i, f, o, I_ROWS, I_COLS, F_ROWS, F_COLS);
  zero_matrix(o, O_ROWS, O_COLS);

  int time = 0;

  start_cycle_timing;
  naive_convolution(i, f, o, I_ROWS, I_COLS, F_ROWS, F_COLS);
  stop_cycle_timing;
  time = get_time();
  print_matrix(o, O_ROWS, O_COLS);
  zero_matrix(o, O_ROWS, O_COLS);
  printf("Naive : %d cycles\n", time);
  fprintf(file, "%s,%d,%d,%d,%d,%d\n","Naive",I_ROWS,I_COLS,F_ROWS,F_COLS,time);

  // Naive, hard-coded size
  start_cycle_timing;
  naive_convolution_hard_size(i, f, o);
  stop_cycle_timing;
  time = get_time();
  print_matrix(o, O_ROWS, O_COLS);
  zero_matrix(o, O_ROWS, O_COLS);
  printf("Naive hard size: %d cycles\n", time);
  fprintf(file, "%s,%d,%d,%d,%d,%d\n","Naive hard size",I_ROWS,I_COLS,F_ROWS,F_COLS,time);

  // Nature
  start_cycle_timing;
  conv2df(i, I_ROWS, I_COLS, f, F_ROWS, F_COLS, o);
  stop_cycle_timing;
  time = get_time();
  print_matrix(o, O_ROWS, O_COLS);
  zero_matrix(o, O_ROWS, O_COLS);
  printf("Nature : %d cycles\n", time);
  fprintf(file, "%s,%d,%d,%d,%d,%d\n","Nature",I_ROWS,I_COLS,F_ROWS,F_COLS,time);

  // Rosette
  start_cycle_timing;
  kernel(i, f, o);
  stop_cycle_timing;
  time = get_time();
  print_matrix(o, O_ROWS, O_COLS);
  zero_matrix(o, O_ROWS, O_COLS);
  printf("Rosette : %d cycles\n", time);
  fprintf(file, "%s,%d,%d,%d,%d,%d\n","Rosette",I_ROWS,I_COLS,F_ROWS,F_COLS,time);

  return 0;
}

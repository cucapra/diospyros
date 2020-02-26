#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#include "..diospyros-private/src/utils.h"

void kernel(float * input_I, float * input_F, float * input_O);

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

  // Naive
  start_cycle_timing();
  naive_convolution(i, f, o, I_ROWS, I_COLS, F_ROWS, F_COLS);
  time = stop_cycle_timing();
  print_matrix(o, O_ROWS, O_COLS);
  zero_matrix(o, O_ROWS, O_COLS);
  printf("Naive : %d cycles\n", time);

  // Naive, hard-coded size
  start_cycle_timing();
  naive_convolution_hard_size(i, f, o);
  time = stop_cycle_timing();
  print_matrix(o, O_ROWS, O_COLS);
  zero_matrix(o, O_ROWS, O_COLS);
  printf("Naive hard size: %d cycles\n", time);

  // Nature
  start_cycle_timing();
  conv2df(i, I_ROWS, I_COLS, f, F_ROWS, F_COLS, o);
  time = stop_cycle_timing();
  print_matrix(o, O_ROWS, O_COLS);
  zero_matrix(o, O_ROWS, O_COLS);
  printf("Nature : %d cycles\n", time);

  // Rosette
  start_cycle_timing();
  kernel(i, f, o);
  time = stop_cycle_timing();
  print_matrix(o, O_ROWS, O_COLS);
  zero_matrix(o, O_ROWS, O_COLS);
  printf("Rosette : %d cycles\n", time);

  return 0;
}

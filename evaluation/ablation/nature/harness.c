#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <Eigen/Core>
#include <Eigen/Dense>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#include "utils.h"

float a[A_ROWS * A_COLS] __attribute__((section(".dram0.data")));
float b[B_ROWS * B_COLS] __attribute__((section(".dram0.data")));
float c[A_ROWS * B_COLS] __attribute__((section(".dram0.data")));

float c_spec[A_ROWS * B_COLS] __attribute__((section(".dram0.data")));

extern "C" {
  // Nature kernel
  void matmmltf(const float32_t *x, int M, int N, const float32_t *y,
    int P, float32_t *z);
}

// Diospyros kernel
void kernel(float* input_A, float* input_B, float* input_C);


// Naive
void naive_matrix_multiply(float *a, float *b, float *c, int row1, int col1, int col2) {
  for (int y = 0; y < row1; y++) {
    for (int x = 0; x < col2; x++) {
      c[col2 * y + x] = 0;
      for (int k = 0; k < col1; k++) {
        c[col2 * y + x] += a[col1 * y + k] * b[col2 * k + x];
      }
    }
  }
}

 // Naive hard-coded size
 void naive_matrix_multiply_hard_size(float *a, float *b, float *c) {
   for (int y = 0; y < A_ROWS; y++) {
     for (int x = 0; x < B_COLS; x++) {
       c[B_COLS * y + x] = 0;
       for (int k = 0; k < A_COLS; k++) {
         c[B_COLS * y + x] += a[A_COLS * y + k] * b[B_COLS * k + x];
       }
     }
   }
 }


int main(int argc, char **argv) {

  init_rand(10);

  create_random_mat(a, A_ROWS, A_COLS);
  create_random_mat(b, B_ROWS, B_COLS);
  zero_matrix(c, A_ROWS, B_COLS);

  // Run naive once to warm cache
  naive_matrix_multiply(a, b, c_spec,  A_ROWS, A_COLS, B_COLS);
  zero_matrix(c, A_ROWS, B_COLS);

  int time = 0;

  // Nature
  start_cycle_timing;
  matmmltf(a, A_ROWS, A_COLS, b, B_COLS, c);
  stop_cycle_timing;
  time = get_time();
  output_check(c, c_spec, A_ROWS, B_COLS);
  zero_matrix(c, A_ROWS, B_COLS);
  printf("%d\n", time);

  return 0;
}

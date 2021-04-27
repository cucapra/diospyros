#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#include "../evaluation/src/utils.h"

#define SIZE 8

void matrix_multiply(float a_in[SIZE], float scalar_in, float b_out[SIZE]) {
  for (int i = 0; i < SIZE; i++) {
    b_out[i] = a_in[i] * scalar_in;
  }
}

float a[SIZE] __attribute__((section(".dram0.data")));
float b_ref[SIZE] __attribute__((section(".dram0.data")));
float b[SIZE] __attribute__((section(".dram0.data")));

float scalar = 2;

// Diospyros kernel
void kernel(float * a_in, float scalar_in, float * b_out);

int main(int argc, char **argv) {

  init_rand(10);

  create_random_mat(a, 1, SIZE);
  zero_matrix(b_ref, 1, SIZE);
  zero_matrix(b, 1, SIZE);

  print_matrix(a, 1, SIZE);

  int time = 0;
  start_cycle_timing;
  matrix_multiply(a, scalar, b_ref);
  stop_cycle_timing;
  time = get_time();
  print_matrix(b_ref, 1, SIZE);
  printf("Naive: %d cycles\n", time);

  start_cycle_timing;
  kernel(a, scalar, b);
  stop_cycle_timing;
  time = get_time();
  print_matrix(b, 1, SIZE);
  output_check(b_ref, b, 1, SIZE);
  printf("Diospyros: %d cycles\n", time);

  return 0;
}

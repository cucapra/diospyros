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

float a[N] __attribute__((section(".dram0.data")));
float q[N] __attribute__((section(".dram0.data")));
float q_spec[N] __attribute__((section(".dram0.data")));

// Diospyros kernel
void kernel(float * input_N);

int main(int argc, char **argv) {

  FILE *file = fopen(OUTFILE, "w");
  if (file == NULL) return -1;

  init_rand(10);

  create_random_mat(a, 1, N);
  zero_matrix(q, 1, N);
  zero_matrix(q, 1, N);

  print_matrix(a, 1, N);


  int time = 0;

  // Diospyros
  start_cycle_timing;
  kernel(a);
  stop_cycle_timing;
  time = get_time();
  print_matrix(q, O_ROWS, O_COLS);
  printf("Diospyros : %d cycles\n", time);

  return 0;
}

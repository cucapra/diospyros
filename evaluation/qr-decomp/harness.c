#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#include "../../../../diospyros-private/src/utils.h"

float a[N * N] __attribute__((section(".dram0.data")));
float q[N * N] __attribute__((section(".dram0.data")));
float r[N * N] __attribute__((section(".dram0.data")));
float q_spec[N * N] __attribute__((section(".dram0.data")));
float r_spec[N * N] __attribute__((section(".dram0.data")));

// Diospyros kernel
void kernel(float * A, float * Q, float * R);

int main(int argc, char **argv) {

  FILE *file = fopen(OUTFILE, "w");
  if (file == NULL) file = stdout;;

  init_rand(10);

  create_random_mat(a, N, N);
  zero_matrix(q, N, N);
  zero_matrix(r, N, N);

  print_matrix(a, N, N);


  int time = 0;

  // Diospyros
  start_cycle_timing;
  kernel(a, q, r);
  stop_cycle_timing;
  time = get_time();
  print_matrix(q, N, N);
  printf("Diospyros : %d cycles\n", time);

  return 0;
}

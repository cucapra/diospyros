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

float a_q[4] __attribute__((section(".dram0.data")));
float a_t[3] __attribute__((section(".dram0.data")));
float b_q[4] __attribute__((section(".dram0.data")));
float b_t[3] __attribute__((section(".dram0.data")));
float r_q[4] __attribute__((section(".dram0.data")));
float r_t[4] __attribute__((section(".dram0.data")));
// Diospyros kernel
void kernel(float * a_q, float * a_t, float * b_q, float * b_t, /* inputs */
            float * r_q, float * r_t);                          /* outputs */

// // Nature functions.
// extern "C" {
// }

int main(int argc, char **argv) {

  FILE *file = fopen(OUTFILE, "w");
  if (file == NULL) file = stdout;;

  init_rand(10);

  create_random_mat(a_q, 4, 1);
  create_random_mat(a_t, 3, 1);
  create_random_mat(b_q, 4, 1);
  create_random_mat(b_t, 3, 1);


  zero_matrix(r_q, 4, 1);
  zero_matrix(r_t, 4, 1);

  print_matrix(a_q, 4, 1);
  print_matrix(a_t, 3, 1);
  print_matrix(b_q, 4, 1);
  print_matrix(b_t, 3, 1);

  int time = 0;

  // Diospyros
  start_cycle_timing;
  kernel(a_q, a_t, b_q, b_t, r_q, r_t);
  stop_cycle_timing;
  time = get_time();
  print_matrix(r_q, 4, 1);
  print_matrix(r_t, 4, 1);
  printf("Diospyros : %d cycles\n", time);

  return 0;
}

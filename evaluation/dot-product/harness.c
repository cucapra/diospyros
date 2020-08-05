#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#include "../diospyros-private/src/utils.h"

float a[A_ROWS * A_COLS] __attribute__((section(".dram0.data")));
float b[B_ROWS * B_COLS] __attribute__((section(".dram0.data")));
float c[A_ROWS * B_COLS] __attribute__((section(".dram0.data")));

float c_spec[A_ROWS * B_COLS] __attribute__((section(".dram0.data")));

// Diospyros kernel
void kernel(float* input_A, float* input_B, float* input_C);

int main(int argc, char **argv) {

 // FILE *file = fopen(OUTFILE, "w");
 // if (file == NULL) return -1;
 // fprintf(file, "kernel,A_ROWS,A_COLS,B_ROWS,B_COLS,cycles\n");

  init_rand(10);

  create_random_mat(a, 2, 2);
  create_random_mat(b, 2, 2);
  zero_matrix(c, 2, 2);

  print_matrix(a, 2, 2);
  print_matrix(b, 2, 2);
}

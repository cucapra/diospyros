#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

// XXX Adrian temporarily modified this because the private directory is
// directly alongside the public directory in his setup...
#include "../../../diospyros-private/src/utils.h"

float a[N * N] __attribute__((section(".dram0.data")));
float q[N * N] __attribute__((section(".dram0.data")));
float r[N * N] __attribute__((section(".dram0.data")));
float q_spec[N * N] __attribute__((section(".dram0.data")));
float r_spec[N * N] __attribute__((section(".dram0.data")));

// For Nature.
float scratch[N] __attribute__((section(".dram0.data")));
float nat_v[(2*N-N+1)*(N/2+N)] __attribute__((section(".dram0.data")));
float nat_d[N] __attribute__((section(".dram0.data")));

// Diospyros kernel
void kernel(float * A, float * Q, float * R);

// Nature functions.
extern "C" {
  void matinvqrf(void *pScr,
                 float32_t* A,float32_t* V,float32_t* D, int M, int N_);
  size_t matinvqrf_getScratchSize(int M, int N_);
}

int main(int argc, char **argv) {

  FILE *file = fopen(OUTFILE, "w");
  if (file == NULL) file = stdout;;

  init_rand(10);

  create_random_mat(a, N, N);
  zero_matrix(q, N, N);
  zero_matrix(r, N, N);

  print_matrix(a, N, N);


  int time = 0;

  // Nature.
  size_t scratchSize = matinvqrf_getScratchSize(N, N);
  if (sizeof(scratch) < scratchSize) {
    printf("scratch is too small!\n");
    return 1;
  }
  matinvqrf(scratch, a, nat_v, nat_d, N, N);
  print_matrix(a, N, N);  // `a` now holds R (upper triangle).
  print_matrix(nat_d, N, 1);  // d is just the recip. of the diagonal of R (so useless?).
  print_matrix(nat_v, 2*N-N+1, N/2+N);
  return 0;

  // Diospyros
  start_cycle_timing;
  kernel(a, q, r);
  stop_cycle_timing;
  time = get_time();
  print_matrix(q, N, N);
  printf("Diospyros : %d cycles\n", time);

  return 0;
}

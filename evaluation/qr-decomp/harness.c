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
float nat_b[N*N] __attribute__((section(".dram0.data")));

// Diospyros kernel
void kernel(float * A, float * Q, float * R);

// Nature functions.
extern "C" {
  void matinvqrf(void *pScr,
                 float32_t* A,float32_t* V,float32_t* D, int M, int N_);
  size_t matinvqrf_getScratchSize(int M, int N_);
  void matinvqrrotf(void *pScr,                                              
                    float32_t* B, const float32_t* V,                         
                    int M, int N_, int P);
  size_t matinvqrrotf_getScratchSize(int M, int N_, int P);
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

  // We need an extra identity matrix for the second step.
  zero_matrix(nat_b, N, N);
  for (int i = 0; i < N; ++i) {
    nat_b[i*N + i] = 1;
  }

  // Start with main QR decomposition call.
  size_t scratchSize = matinvqrf_getScratchSize(N, N);
  if (sizeof(scratch) < scratchSize) {
    printf("scratch is too small!\n");
    return 1;
  }
  matinvqrf(scratch, a, nat_v, nat_d, N, N);
  printf("R:\n");  // `a` now holds R (upper triangular).
  print_matrix(a, N, N);
  
  // Apply Housholder rotations to obtain Q.
  print_matrix(nat_v, 2*N-N+1, N/2+N);
  scratchSize = matinvqrrotf_getScratchSize(N, N, N);
  if (sizeof(scratch) < scratchSize) {
    printf("scratch is too small!\n");
    return 1;
  }
  matinvqrrotf(scratch, nat_b, nat_v, N, N, N);
  printf("Q:\n");
  print_matrix(nat_b, N, N);
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

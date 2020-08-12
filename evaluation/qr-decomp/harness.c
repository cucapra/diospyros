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
  void transpmf(const float32_t * x, int M, int N_, float32_t * z);
}

/**
 * QR decomposition using Nature kernels.
 */
int nature_qr(const float *A, float *Q, float *R) {
  // Check that our scratch array is big enough for both steps.
  size_t scratchSize = matinvqrf_getScratchSize(N, N);
  if (sizeof(scratch) < scratchSize) {
    printf("scratch is too small for matinvqrf!\n");
    return 1;
  }
  scratchSize = matinvqrrotf_getScratchSize(N, N, N);
  if (sizeof(scratch) < scratchSize) {
    printf("scratch is too small for matinvqrrotf!\n");
    return 1;
  }

  // Copy A into R (because it's overwritten in the first step).
  for (int i = 0; i < N * N; ++i) {
    R[i] = A[i];
  }

  // Start with main QR decomposition call.
  // The `R` used here is an in/out parameter: A in input, R on output.
  matinvqrf(scratch, R, nat_v, nat_d, N, N);

  // We need an extra identity matrix for the second step.
  zero_matrix(nat_b, N, N);
  for (int i = 0; i < N; ++i) {
    nat_b[i*N + i] = 1;
  }

  // Apply Householder rotations to obtain Q'.
  matinvqrrotf(scratch, nat_b, nat_v, N, N, N);

  // Transpose that to get Q.
  transpmf(nat_b, N, N, Q);
  return 0;
}

int main(int argc, char **argv) {

  FILE *file = fopen(OUTFILE, "w");
  if (file == NULL) file = stdout;

  fprintf(file, "kernel,N,cycles\n");

  init_rand(10);

  create_random_mat(a, N, N);
  zero_matrix(q, N, N);
  zero_matrix(r, N, N);
  zero_matrix(q_spec, N, N);
  zero_matrix(r_spec, N, N);

  print_matrix(a, N, N);

  int err;
  int time = 0;;

  if (N % 4 == 0) {
    printf("Starting Nature spec run\n");
    // Use Nature as spec for now
    err = nature_qr(a, q_spec, r_spec);
    if (err) {
      return err;
    }
    // Nature
    start_cycle_timing;
    err = nature_qr(a, q, r);
    stop_cycle_timing;
    if (err) {
      return err;
    }
    time = get_time();
    print_matrix(q, N, N);
    zero_matrix(q, N, N);
    zero_matrix(r, N, N);
    printf("Nature : %d cycles\n", time);
    fprintf(file, "%s,%d,%d\n","Nature",N,time);
  }

  // Diospyros
  start_cycle_timing;
  kernel(a, q, r);
  stop_cycle_timing;
  time = get_time();
  print_matrix(q, N, N);
  print_matrix(r, N, N);
  printf("Diospyros : %d cycles\n", time);
  if (N % 4 == 0) {
    output_check_abs(q, q_spec, N, N);
    output_check_abs(r, r_spec, N, N);
  }
  fprintf(file, "%s,%d,%d\n","Diospyros",N,time);

  return 0;
}

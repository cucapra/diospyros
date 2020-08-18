#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

float sgn(float v);

float naive_norm(float *x, int m) {
  print_matrix(x, m, 1);
  int sum = 0;
  for (int i = 0; i < m; i++) {
    printf("x[i] %f\n", x[i]);
    printf("x[i]^2  %f\n", pow(x[i], 2));
    sum += pow(x[i], 2);
  }
  return sqrt(sum);
}

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

void naive_qr_decomp(float *A, float *Q, float *R, int n) {
  memcpy(R, A, sizeof(float) * n * n);

  // Build identity matrix of size n * n
  float *I = (float *)calloc(sizeof(float), n * n);
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      I[i*n + j] = (i == j);
    }
  }

  // Householder
  for (int k = 0; k < n - 1; k++) {
    int m = n - k;
    float *x = (float *)calloc(sizeof(float), m);
    float *e = (float *)calloc(sizeof(float), m);
    for (int i = 0; i < m; i++) {
      int row = k + i;
      x[i] = R[row*n + k];
      e[i] = I[row*n + k];
    }

    printf("x\n");
    print_matrix(x, m, 1);

    printf("e\n");
    print_matrix(e, m, 1);


    float alpha = -sgn(x[0]) * naive_norm(x, m);

    printf("norm(x) %f\n", naive_norm(x, m));
    printf("alpha %f\n", alpha);

    float *u = (float *)calloc(sizeof(float), m);
    float *v = (float *)calloc(sizeof(float), m);


    for (int i = 0; i < m; i++) {
      u[i] = x[i] + alpha * e[i];
    }
    float norm_u = naive_norm(u, m);
    for (int i = 0; i < m; i++) {
      v[i] = u[i]/norm_u;
    }

    printf("v\n");
    print_matrix(v, m, 1);

    float *q_min = (float *)calloc(sizeof(float), m * m);
    for (int i = 0; i < m; i++) {
      for (int j = 0; j < m; j++) {
        float q_min_i = ((i == j) ? 1.0 : 0.0) - 2 * v[i] * v[j];
        q_min[i*n + j] = q_min_i;
      }
    }
    float *q_t = (float *)calloc(sizeof(float), n * n);
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        float q_t_i;
        if ((i < k) || (j < k)) {
          q_t_i = (i == j) ? 1.0 : 0.0;
        } else {
          q_t_i =  q_min[(i - k)*n + (k - k)];
        }
        q_t[i*n + j] = q_t_i;
      }
    }

    if (k == 0) {
      memcpy(Q, q_t, sizeof(float) * n * n);     // Q = q_t
      naive_matrix_multiply(q_t, A, R, n, n, n); // R = q_t * A
    } else {
      float *res = (float *)calloc(sizeof(float), n * n);
      naive_matrix_multiply(q_t, Q, res, n, n, n); // R = q_t * A
      memcpy(Q, res, sizeof(float) * n * n);
      naive_matrix_multiply(q_t, R, res, n, n, n); // R = q_t * A
      memcpy(R, res, sizeof(float) * n * n);
    }
    free(x);
    free(e);
    free(u);
    free(v);
    free(q_min);
    free(q_t);
  }

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
    print_matrix(r, N, N);
    zero_matrix(q, N, N);
    zero_matrix(r, N, N);
    printf("Nature : %d cycles\n", time);
    fprintf(file, "%s,%d,%d\n","Nature",N,time);
  }

  // Naive
  start_cycle_timing;
  naive_qr_decomp(a, q, r, N);
  stop_cycle_timing;
  time = get_time();
  print_matrix(q, N, N);
  print_matrix(r, N, N);
  printf("Naive : %d cycles\n", time);
  // output_check_abs(q, q_spec, N, N);
  // output_check_abs(r, r_spec, N, N);
  fprintf(file, "%s,%d,%d\n","Naive",N,time);

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

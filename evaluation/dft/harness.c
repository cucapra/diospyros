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

float x[N] __attribute__((section(".dram0.data")));
float x_real[N] __attribute__((section(".dram0.data")));
float x_img[N] __attribute__((section(".dram0.data")));
float P[N] __attribute__((section(".dram0.data")));

float x_real_spec[N] __attribute__((section(".dram0.data")));
float x_img_spec[N] __attribute__((section(".dram0.data")));

// Diospyros kernel
void kernel(float * input_x, float * input_x_real, float * input_x_img,
  float * input_P);

// Naive
void naive_dft(float *x, float *x_real, float *x_img, int n);

// Naive hard-coded size
void naive_dft_hard_size(float *x, float *x_real, float *x_img);

// Nature kernel
// Nature required "twiddle factor table"
const complex_float twiddle_factor[3*N/4];

void cfftd(const complex_double * in, complex_double * out,
  const complex_double twiddle_table[], int twiddle_stride, int N);


int main(int argc, char **argv) {

  FILE *file = fopen(OUTFILE, "w");
  if (file == NULL) return -1;
  fprintf(file, "kernel,N,cycles\n");

  init_rand(10);

  create_random_mat(x, 1, N);
  zero_matrix(x_real, 1, N);
  zero_matrix(x_img, 1, N);
  zero_matrix(x_real_spec, 1, N);
  zero_matrix(x_img_spec, 1, N);

  print_matrix(x, 1, N);

  // Run naive once to warm cache
  naive_dft(x, x_real_spec, x_img_spec, N);

  int time = 0;

  // Naive
  start_cycle_timing;
  naive_dft(x, x_real, x_img, N);
  stop_cycle_timing;
  time = get_time();
  print_matrix(x_real, 1, N);
  print_matrix(x_img, 1, N);
  output_check(x_real, x_real_spec, 1, N);
  output_check(x_img, x_img_spec, 1, N);
  zero_matrix(x_real, 1, N);
  zero_matrix(x_img, 1, N);
  printf("Naive : %d cycles\n", time);
  fprintf(file, "%s,%d,%d\n","Naive",N,time);

  // Naive, hard-coded size
  start_cycle_timing;
  naive_dft_hard_size(x, x_real, x_img);
  stop_cycle_timing;
  time = get_time();
  print_matrix(x_real, 1, N);
  print_matrix(x_img, 1, N);
  output_check(x_real, x_real_spec, 1, N);
  output_check(x_img, x_img_spec, 1, N);
  zero_matrix(x_real, 1, N);
  zero_matrix(x_img, 1, N);
  printf("Naive hard size: %d cycles\n", time);
  fprintf(file, "%s,%d,%d\n","Naive hard size",N,time);

  // Nature
  start_cycle_timing;
  // TODO: convert from two arrays to a complex array
  cfftd(x, x_real, twiddle_factor, 1, N);
  stop_cycle_timing;
  time = get_time();
  print_matrix(x_real, 1, N);
  print_matrix(x_img, 1, N);
  output_check(x_real, x_real_spec, 1, N);
  output_check(x_img, x_img_spec, 1, N);
  zero_matrix(x_real, 1, N);
  zero_matrix(x_img, 1, N);
  printf("Nature : %d cycles\n", time);
  fprintf(file, "%s,%d,%d\n","Nature",N,time);

  // Diospyros
  start_cycle_timing;
  kernel(x, x_real, x_img, P);
  stop_cycle_timing;
  time = get_time();
  print_matrix(x_real, 1, N);
  print_matrix(x_img, 1, N);
  output_check(x_real, x_real_spec, 1, N);
  output_check(x_img, x_img_spec, 1, N);
  zero_matrix(x_real, 1, N);
  zero_matrix(x_img, 1, N);
  printf("Diospyros : %d cycles\n", time);
  fprintf(file, "%s,%d,%d,\n","Diospyros",N,time);

  return 0;
}

#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

// Nature
#include <math_floating_scalar.h>
#include <math_fixedpoint_scalar.h>

#include "../../../diospyros-private/src/utils.h"

float x[N] __attribute__((section(".dram0.data")));
float x_real[N] __attribute__((section(".dram0.data")));
float x_img[N] __attribute__((section(".dram0.data")));
float P[N] __attribute__((section(".dram0.data")));

float x_real_spec[N] __attribute__((section(".dram0.data")));
float x_img_spec[N] __attribute__((section(".dram0.data")));

#define PI 3.1415926535897932384626433832795

// Diospyros kernel
void kernel(float * input_x, float * input_x_real, float * input_x_img,
  float * input_P);

// Nature sin and cos
float64_t cos(float64_t x);
float64_t sin(float64_t x);

xb_vecMxf32 cos_MXF32(xb_vecMxf32 v) {
  float values[4];
  float * __restrict ptr = values;
  valign align;
  PDX_SAV_MXF32_XP(v, align, (xb_vecMxf32 *) ptr, 16);
  for (int i = 0; i < 4; i++) {
    values[i] = cos(values[i]);
  }
  return *((xb_vecMxf32 *) values);
}

xb_vecMxf32 sin_MXF32(xb_vecMxf32 v) {
  float values[4];
  float * __restrict ptr = values;
  valign align;
  PDX_SAV_MXF32_XP(v, align, (xb_vecMxf32 *) ptr, 16);
  for (int i = 0; i < 4; i++) {
    values[i] = sin(values[i]);
  }
  return *((xb_vecMxf32 *) values);
}

// Naive
void naive_dft(float *x, float *x_real, float *x_img, int n) {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      x_real[j] += x[i] * cos((2 * i * j * PI) / n);
      x_img[j] -= x[i] * sin((2 * i * j * PI) / n);
    }
  }
}

// Naive hard-coded size
void naive_dft_hard_size(float *x, float *x_real, float *x_img)  {
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      x_real[j] += x[i] * cos((2 * i * j * PI) / N);
      x_img[j] -= x[i] * sin((2 * i * j * PI) / N);
    }
  }
}

// Nature kernel
// Nature required "twiddle factor table"
const complex_float twiddle_factor[3*N/4];

void cfft(const complex_float * x, complex_float * y,
  const complex_float twiddle_table[], int twiddle_stride, int n);

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

  printf("Input matrix\n");
  print_matrix(x, 1, N);

  // Run naive once to warm cache
  naive_dft(x, x_real_spec, x_img_spec, N);

  printf("Reference results\n");

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
  // Need to convert to a complex float array, don't count that in timing
  complex_float x_complex[N];
  complex_float x_results_complex[N];
  for (int i = 0; i < N; i++) {
    x_complex[i] = x[i] + 0 * I;
  }

  start_cycle_timing;
  cfft(x_complex, x_results_complex, twiddle_factor, 1, N);
  stop_cycle_timing;
  time = get_time();

  // Need to convert from a complex float array, don't count that in timing
  for (int i = 0; i < N; i++) {
    x_real[i] = __real__ x_results_complex[i];
    x_img[i] = __imag__ x_results_complex[i];
  }
  print_matrix(x_real, 1, N);
  print_matrix(x_img, 1, N);
  // output_check(x_real, x_real_spec, 1, N);
  // output_check(x_img, x_img_spec, 1, N);
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
  // output_check(x_real, x_real_spec, 1, N);
  // output_check(x_img, x_img_spec, 1, N);
  zero_matrix(x_real, 1, N);
  zero_matrix(x_img, 1, N);
  printf("Diospyros : %d cycles\n", time);
  fprintf(file, "%s,%d,%d,\n","Diospyros",N,time);

  return 0;
}

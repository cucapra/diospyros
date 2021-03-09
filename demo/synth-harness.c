#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#include "evaluation/src/utils.h"

float xyz[3] __attribute__((section(".dram0.data")));
float d_in[2] __attribute__((section(".dram0.data")));
float e_out[2] __attribute__((section(".dram0.data")));

float e_out_spec[2] __attribute__((section(".dram0.data")));

void foo(
    float x_in,
    float y_in,
    float z_in,
    float d_in[2],
    float e_out[2]) {

  if (d_in[0] < 0.5f) {
    d_in[1] = 2.0f + d_in[0];
  }

  if (x_in - z_in - y_in < 2.0f || x_in > z_in && y_in + z_in < 5.0f) {
    e_out[0] = 0.0f;
    e_out[1] = 0.1f;
  } else {
    if (d_in[0] > d_in[1]) {
      e_out[0] = -x_in;
      e_out[1] = y_in * z_in;
    } else {
      e_out[0] = x_in;
      e_out[1] = -y_in * y_in;
    }
  }
  float t = d_in[0] * d_in[0] + d_in[1] * d_in[1];
  e_out[0] = e_out[0] / t;
  e_out[1] = e_out[1] / t;
}

// Diospyros kernel
void kernel(float x_in, float y_in, float z_in, float * d_in, float * e_out);


int main(int argc, char **argv) {
  init_rand(10);

  create_random_mat(xyz, 3, 1);
  create_random_mat(d_in, 2, 1);
  zero_matrix(e_out, 2, 1);
  zero_matrix(e_out_spec, 2, 1);

  print_matrix(xyz, 3, 1);
  print_matrix(d_in, 2, 1);

  int time = 0;

  // Naive
  start_cycle_timing;
  foo(xyz[0], xyz[1], xyz[2], d_in, e_out_spec);
  stop_cycle_timing;
  time = get_time();
  print_matrix(e_out_spec, 2, 1);
  printf("Naive : %d cycles\n", time);

  // Diospyros
  start_cycle_timing;
  kernel(xyz[0], xyz[1], xyz[2], d_in, e_out);
  stop_cycle_timing;
  time = get_time();
  print_matrix(e_out, 2, 1);
  output_check(e_out, e_out_spec, 2, 1);
  printf("Diospyros : %d cycles\n", time);
  return 0;
}

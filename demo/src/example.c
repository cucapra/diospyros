#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "../../evaluation/src/utils.h"

#include "transpose_and_multiply.h"

#define A_SIZE 3
#define B_ROWS 3
#define B_COLS 4

#define ITERATIONS 2

#if defined(__XTENSA__)
#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

float a[A_SIZE * A_SIZE * ITERATIONS] __attribute__((section(".dram0.data")));
float b[B_ROWS * B_COLS * ITERATIONS] __attribute__((section(".dram0.data")));
float c[A_SIZE * B_COLS * ITERATIONS] __attribute__((section(".dram0.data")));
float c_spec[A_SIZE * B_COLS * ITERATIONS] __attribute__((section(".dram0.data")));
#else
float a[A_SIZE * A_SIZE * ITERATIONS];
float b[B_ROWS * B_COLS * ITERATIONS];
float c[A_SIZE * B_COLS * ITERATIONS];
float c_spec[A_SIZE * B_COLS * ITERATIONS];
#endif // defined(__XTENSA__)

 // Naive hard-coded size implementation
 void matrix_multiply(float *a, float *b, float *c) {
   for (int y = 0; y < A_SIZE; y++) {
     for (int x = 0; x < B_COLS; x++) {
       c[B_COLS * y + x] = 0;
       for (int k = 0; k < A_SIZE; k++) {
         c[B_COLS * y + x] += a[A_SIZE * y + k] * b[B_COLS * k + x];
       }
     }
   }
 }

 // Naive implementation
void transpose(float *a, float *out, int n) {
  for (int i = 0; i < n; i++) {
    for (int j = i; j < n; j++) {
      out[i*n + j] = a[j*n + i];
    }
  }
}

// Kernel to process ITERATIONS many data elements: multiply the transpose of
// a section of a by the corresponding section of b.
void process_data(float *a, float *b, float *c) {

  float *a_ref = a;
  float *b_ref = b;
  float *c_ref = c;

  for (int k = 0; k <  ITERATIONS; k++) {
    // Transpose a
    diospyros::transpose_and_multiply(a_ref, b_ref, c_ref);

    // Bump pointers
    a_ref += (A_SIZE*A_SIZE);
    b_ref += (B_ROWS*B_COLS);
    c_ref += (A_SIZE*B_COLS);
  }
}


int main(int argc, char **argv) {

  init_rand(10);

  float *a_ref = a;
  float *b_ref = b;
  float *c_ref = c;

  for (int k = 0; k < ITERATIONS; k++) {
    create_random_mat(a_ref, A_SIZE, A_SIZE);
    create_random_mat(b_ref, B_ROWS, B_COLS);
    zero_matrix(c_ref, A_SIZE, B_COLS);
    a_ref += A_SIZE*A_SIZE;
    b_ref += B_ROWS*B_COLS;
    c_ref += A_SIZE*B_COLS;
  }

  int time = 0;

  // Time existing code
  #if defined(__XTENSA__)
  start_cycle_timing;
  #endif // defined(__XTENSA__)

  process_data(a, b, c);

  #if defined(__XTENSA__)
  stop_cycle_timing;
  time = get_time();
  printf("Naive : %d cycles\n", time);
  #endif // defined(__XTENSA__)

  c_ref = c;
  for (int k = 0; k < ITERATIONS; k++) {
    print_matrix(c_ref, A_SIZE, B_COLS);
    c_ref += A_SIZE*B_COLS;
  }

  return 0;
}

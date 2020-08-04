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

int __attribute__((section(".dram0.data"))) Z[4] = {0, 0, 0, 0};
int __attribute__((section(".dram0.data"))) v_1[4] = {0, 1, 2, 3};
void kernel(float * input_A, float * input_B, float * input_C) {
float * __restrict A = input_A;
  valign align_A;
  align_A = PDX_LA_MXF32_PP((xb_vecMxf32 *) input_A);
  float * __restrict B = input_B;
  valign align_B;
  align_B = PDX_LA_MXF32_PP((xb_vecMxf32 *) input_B);
  float * __restrict C = input_C;
  valign align_C;
  xb_vecMxf32 A_0_4;
  PDX_LAV_MXF32_XP(A_0_4, align_A, (xb_vecMxf32 *) A, 16);
  xb_vecMxf32 B_0_4;
  PDX_LAV_MXF32_XP(B_0_4, align_B, (xb_vecMxf32 *) B, 16);
  xb_vecMxf32 v_0;
  v_0 = *((xb_vecMxf32 *) Z);
  xb_vecMxf32 reg_C;
  xb_vecMxf32 v_3;
  v_3 = A_0_4;
  xb_vecMxf32 v_4;
  v_4 = B_0_4;
  reg_C = v_0;
  xb_vecMxf32 v_5;
  v_5 = PDX_ADD_MXF32(v_3, v_4);
  v_0 = v_5;
  xb_vecMxf32 v_8;
  v_8 = A_0_4;
  xb_vecMxf32 v_9;
  v_9 = B_0_4;
  reg_C = v_0;
  xb_vecMxf32 v_10;
  v_10 = PDX_ADD_MXF32(v_8, v_9);
  v_0 = v_10;
  PDX_SAV_MXF32_XP(v_0, align_C, (xb_vecMxf32 *) C, 16);
}

float a[A_ROWS * A_COLS] __attribute__((section(".dram0.data")));
float b[B_ROWS * B_COLS] __attribute__((section(".dram0.data")));
float c[A_ROWS * B_COLS] __attribute__((section(".dram0.data")));

float c_spec[A_ROWS * B_COLS] __attribute__((section(".dram0.data")));

// Diospyros kernel
void kernel(float* input_A, float* input_B, float* input_C);

// Naive
void naive_matrix_add(float *a, float *b, float *c, int row1, int col1, int col2) {
   for (int y = 0; y < row1; y++) {
     for (int x = 0; x < col2; x++) {
       c[col2 * y + x] = 0;
       for (int k = 0; k < col1; k++) {
         c[col2 * y + x] += a[col1 * y + k] * b[col2 * k + x];
       }
     }
   }
 }

// Naive hard-coded size
 void naive_matrix_add_hard_size(float *a, float *b, float *c) {
   for (int y = 0; y < A_ROWS; y++) {
     for (int x = 0; x < B_COLS; x++) {
       c[B_COLS * y + x] = 0;
       for (int k = 0; k < A_COLS; k++) {
         c[B_COLS * y + x] += a[A_COLS * y + k] * b[B_COLS * k + x];
       }
     }
   }
 }


// Nature kernel
void matmmltf(const float32_t *x, int M, int N, const float32_t *y,
  int P, float32_t *z);

int main(int argc, char **argv) {
  init_rand(10);

  create_random_mat(a, A_ROWS, A_COLS);
  create_random_mat(b, B_ROWS, B_COLS);
  zero_matrix(c, A_ROWS, B_COLS);

  print_matrix(a, A_ROWS, A_COLS);
  print_matrix(b, B_ROWS, B_COLS);

  // Run naive once to warm cache
  naive_matrix_add(a, b, c_spec,  A_ROWS, A_COLS, B_COLS);

  int time = 0;

  // Naive
  start_cycle_timing;
  naive_matrix_add(a, b, c,  A_ROWS, A_COLS, B_COLS);
  stop_cycle_timing;
  time = get_time();
  print_matrix(c, A_ROWS, B_COLS);
  output_check(c, c_spec, A_ROWS, B_COLS);
  zero_matrix(c, A_ROWS, B_COLS);
  printf("Naive : %d cycles\n", time);
  fprintf(file, "%s,%d,%d,%d,%d,%d\n","Naive",A_ROWS,A_COLS,B_ROWS,B_COLS,time);
 
  // Naive, hard-coded size
  start_cycle_timing;
  naive_matrix_add_hard_size(a, b, c);
  stop_cycle_timing;
  time = get_time();
  print_matrix(c, A_ROWS, B_COLS);
  output_check(c, c_spec, A_ROWS, B_COLS);
  zero_matrix(c, A_ROWS, B_COLS);
  printf("Naive hard size: %d cycles\n", time);
  fprintf(file, "%s,%d,%d,%d,%d,%d\n","Naive hard size",A_ROWS,A_COLS,B_ROWS,B_COLS,time);

  // Nature
  start_cycle_timing;
  matmmltf(a, A_ROWS, A_COLS, b, B_COLS, c);
  stop_cycle_timing;
  time = get_time();
  print_matrix(c, A_ROWS, B_COLS);
  output_check(c, c_spec, A_ROWS, B_COLS);
  zero_matrix(c, A_ROWS, B_COLS);
  printf("Nature : %d cycles\n", time);
  fprintf(file, "%s,%d,%d,%d,%d,%d\n","Nature",A_ROWS,A_COLS,B_ROWS,B_COLS,time);

  // Diospyros
  start_cycle_timing;
  kernel(a, b, c);
  stop_cycle_timing;
  time = get_time();
  print_matrix(c, A_ROWS, B_COLS);
  output_check(c, c_spec, A_ROWS, B_COLS);
  zero_matrix(c, A_ROWS, B_COLS);
  printf("Diospyros : %d cycles\n", time);
  fprintf(file, "%s,%d,%d,%d,%d,%d\n","Diospyros",A_ROWS,A_COLS,B_ROWS,B_COLS,time);

  return 0;
}

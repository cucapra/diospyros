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

float a[2 * 2] __attribute__((section(".dram0.data")));
float b[2 * 2] __attribute__((section(".dram0.data")));
float c[2 * 2] __attribute__((section(".dram0.data")));

int main(int argc, char **argv) {
          init_rand(10);

  create_random_mat(a, 2, 2);
  create_random_mat(b, 2, 2);
  zero_matrix(c, 2, 2);

  print_matrix(a, 2, 2);
  print_matrix(b, 2, 2);
  kernel(a, b, c);
  
  print_matrix(c, 2, 2);
}

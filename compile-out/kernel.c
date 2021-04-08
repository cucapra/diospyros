#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>
/*
Git revision: 9856de5

Warning: dirty git status:
 compile-out/kernel.c  |  58 ----------------------
 src/backup-c-meta.rkt |  16 ++++++
 src/c-meta.rkt        | 134 +++++++++++++++++++++++++++++++++-----------------
 3 files changed, 104 insertions(+), 104 deletions(-)

*/
int __attribute__((section(".dram0.data"))) Z[4] = {0, 0, 0, 0};
float __attribute__((section(".dram0.data"))) v_0[4] = {0.0, 0, 0, 0};
int __attribute__((section(".dram0.data"))) v_1[4] = {0, 0, 2, 2};
int __attribute__((section(".dram0.data"))) v_1_0[4] = {0, 0, 2, 2};
int __attribute__((section(".dram0.data"))) v_3[4] = {0, 1, 0, 1};
int __attribute__((section(".dram0.data"))) v_3_0[4] = {0, 1, 0, 1};
int __attribute__((section(".dram0.data"))) v_6[4] = {1, 1, 3, 3};
int __attribute__((section(".dram0.data"))) v_6_0[4] = {1, 1, 3, 3};
int __attribute__((section(".dram0.data"))) v_8[4] = {2, 3, 2, 3};
int __attribute__((section(".dram0.data"))) v_8_0[4] = {2, 3, 2, 3};
void kernel(float * a_in, float * b_in, float * c_out) {
float * __restrict a_in_mut = a_in;
  valign align_a_in;
  align_a_in = PDX_LA_MXF32_PP((xb_vecMxf32 *) a_in);
  float * __restrict b_in_mut = b_in;
  valign align_b_in;
  align_b_in = PDX_LA_MXF32_PP((xb_vecMxf32 *) b_in);
  float * __restrict c_out_mut = c_out;
  valign align_c_out;
  xb_vecMxf32 a_in_0_4;
  PDX_LAV_MXF32_XP(a_in_0_4, align_a_in, (xb_vecMxf32 *) a_in_mut, 16);
  xb_vecMxf32 b_in_0_4;
  PDX_LAV_MXF32_XP(b_in_0_4, align_b_in, (xb_vecMxf32 *) b_in_mut, 16);
  xb_vecMxf32 v_2;
  v_2 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(a_in_0_4), *((xb_vecMx32 *) v_1_0)));
  xb_vecMxf32 v_4;
  v_4 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(b_in_0_4), *((xb_vecMx32 *) v_3_0)));
  xb_vecMxf32 v_5 = PDX_MUL_MXF32(v_2, v_4);
  xb_vecMxf32 v_7;
  v_7 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(a_in_0_4), *((xb_vecMx32 *) v_6_0)));
  xb_vecMxf32 v_9;
  v_9 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(b_in_0_4), *((xb_vecMx32 *) v_8_0)));
  xb_vecMxf32 v_10 = v_5;
  PDX_MULA_MXF32(v_10, v_7, v_9);
  PDX_SAV_MXF32_XP(v_10, align_c_out, (xb_vecMxf32 *) c_out, 16);
  PDX_SAPOS_MXF32_FP(align_c_out, (xb_vecMxf32 *) c_out);
}
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
Git revision: 632f2f3

Warning: dirty git status:
 cdios.py       |  2 +-
 src/c-meta.rkt | 51 ++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 39 insertions(+), 14 deletions(-)

*/
int __attribute__((section(".dram0.data"))) Z[4] = {0, 0, 0, 0};
float __attribute__((section(".dram0.data"))) v_0[4] = {0, 0, 0, 0};
int __attribute__((section(".dram0.data"))) v_9[4] = {5, 6, 4, 0};
int __attribute__((section(".dram0.data"))) v_9_0[4] = {1, 2, 0, 4};
int __attribute__((section(".dram0.data"))) v_13[4] = {4, 5, 6, 0};
int __attribute__((section(".dram0.data"))) v_13_0[4] = {0, 1, 2, 4};
int __attribute__((section(".dram0.data"))) v_27[4] = {6, 4, 5, 0};
int __attribute__((section(".dram0.data"))) v_27_0[4] = {2, 0, 1, 4};
void kernel(float * q_in, float * p_in, float * result_out) {
float * __restrict q_in_mut = q_in;
  valign align_q_in;
  align_q_in = PDX_LA_MXF32_PP((xb_vecMxf32 *) q_in);
  float * __restrict p_in_mut = p_in;
  valign align_p_in;
  align_p_in = PDX_LA_MXF32_PP((xb_vecMxf32 *) p_in);
  float * __restrict result_out_mut = result_out;
  valign align_result_out;
  xb_vecMxf32 p_in_0_4;
  PDX_LAV_MXF32_XP(p_in_0_4, align_p_in, (xb_vecMxf32 *) p_in_mut, 16);
  float v_1 = q_in[1];
  float v_2 = q_in[2];
  float v_3 = q_in[0];
  float v_4 = 1;
  float v_5_tmp[4] = {v_1, v_2, v_3, v_4};
  xb_vecMxf32 v_5 = *((xb_vecMxf32 *) v_5_tmp);
  float v_6 = 2;
  float v_7_tmp[4] = {v_6, v_6, v_6, v_4};
  xb_vecMxf32 v_7 = *((xb_vecMxf32 *) v_7_tmp);
  float v_8_tmp[4] = {v_3, v_1, v_2, v_4};
  xb_vecMxf32 v_8 = *((xb_vecMxf32 *) v_8_tmp);
  xb_vecMxf32 v_10;
  v_10 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(p_in_0_4), *((xb_vecMx32 *) v_9_0)));
  xb_vecMxf32 v_11 = PDX_MUL_MXF32(v_8, v_10);
  xb_vecMxf32 v_14;
  v_14 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(p_in_0_4), *((xb_vecMx32 *) v_13_0)));
  xb_vecMxf32 v_15 = PDX_MUL_MXF32(v_5, v_14);
  xb_vecMxf32 v_16 = PDX_NEG_MXF32(v_15);
  xb_vecMxf32 v_17 = PDX_ADD_MXF32(v_11, v_16);
  xb_vecMxf32 v_18 = PDX_MUL_MXF32(v_7, v_17);
  xb_vecMxf32 v_19 = PDX_MUL_MXF32(v_5, v_18);
  float v_20_tmp[4] = {v_2, v_3, v_1, v_4};
  xb_vecMxf32 v_20 = *((xb_vecMxf32 *) v_20_tmp);
  xb_vecMxf32 v_25 = PDX_MUL_MXF32(v_20, v_14);
  xb_vecMxf32 v_28;
  v_28 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(p_in_0_4), *((xb_vecMx32 *) v_27_0)));
  xb_vecMxf32 v_29 = PDX_MUL_MXF32(v_8, v_28);
  xb_vecMxf32 v_30 = PDX_NEG_MXF32(v_29);
  xb_vecMxf32 v_31 = PDX_ADD_MXF32(v_25, v_30);
  xb_vecMxf32 v_32 = PDX_MUL_MXF32(v_7, v_31);
  xb_vecMxf32 v_33 = PDX_MUL_MXF32(v_20, v_32);
  xb_vecMxf32 v_34 = PDX_NEG_MXF32(v_33);
  xb_vecMxf32 v_35 = PDX_ADD_MXF32(v_19, v_34);
  float v_38 = q_in[3];
  float v_39_tmp[4] = {v_38, v_38, v_38, v_4};
  xb_vecMxf32 v_39 = *((xb_vecMxf32 *) v_39_tmp);
  xb_vecMxf32 v_44 = PDX_MUL_MXF32(v_5, v_28);
  xb_vecMxf32 v_48 = PDX_MUL_MXF32(v_20, v_10);
  xb_vecMxf32 v_49 = PDX_NEG_MXF32(v_48);
  xb_vecMxf32 v_50 = PDX_ADD_MXF32(v_44, v_49);
  xb_vecMxf32 v_51 = PDX_MUL_MXF32(v_7, v_50);
  xb_vecMxf32 v_52 = v_14;
  PDX_MULA_MXF32(v_52, v_39, v_51);
  xb_vecMxf32 v_53 = PDX_ADD_MXF32(v_35, v_52);
  PDX_SAV_MXF32_XP(v_53, align_result_out, (xb_vecMxf32 *) result_out, 16);
  PDX_SAPOS_MXF32_FP(align_result_out, (xb_vecMxf32 *) result_out);
}
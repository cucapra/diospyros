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
Git revision: 939e0e4

Warning: dirty git status:
 qr-decomp-out/kernel.c  | 1621 +++++++++++++++++++++++++++++++++++------------
 src/examples/q-prod.rkt |    2 +-
 2 files changed, 1233 insertions(+), 390 deletions(-)

*/
int __attribute__((section(".dram0.data"))) Z[4] = {0, 0, 0, 0};
float __attribute__((section(".dram0.data"))) v_0[4] = {0, 0, 0, 0};
int __attribute__((section(".dram0.data"))) v_4[4] = {4, 5, 6, 0};
int __attribute__((section(".dram0.data"))) v_4_0[4] = {0, 1, 2, 4};
int __attribute__((section(".dram0.data"))) v_11[4] = {7, 7, 7, 0};
int __attribute__((section(".dram0.data"))) v_11_0[4] = {3, 3, 3, 4};
int __attribute__((section(".dram0.data"))) v_14[4] = {1, 2, 0, 3};
int __attribute__((section(".dram0.data"))) v_14_0[4] = {1, 2, 0, 3};
int __attribute__((section(".dram0.data"))) v_16[4] = {2, 0, 1, 3};
int __attribute__((section(".dram0.data"))) v_16_0[4] = {2, 0, 1, 3};
int __attribute__((section(".dram0.data"))) v_21[4] = {0, 0, 0, 4};
int __attribute__((section(".dram0.data"))) v_21_0[4] = {0, 0, 0, 4};
int __attribute__((section(".dram0.data"))) v_26[4] = {0, 0, 0, 5};
int __attribute__((section(".dram0.data"))) v_26_0[4] = {0, 0, 0, 5};
int __attribute__((section(".dram0.data"))) v_30[4] = {2, 0, 1, 2};
int __attribute__((section(".dram0.data"))) v_30_0[4] = {2, 0, 1, 2};
int __attribute__((section(".dram0.data"))) v_32[4] = {1, 2, 0, 2};
int __attribute__((section(".dram0.data"))) v_32_0[4] = {1, 2, 0, 2};
int __attribute__((section(".dram0.data"))) v_4_1[4] = {0, 1, 2, 4};
int __attribute__((section(".dram0.data"))) v_4_2[4] = {0, 1, 2, 4};
int __attribute__((section(".dram0.data"))) v_47[4] = {5, 6, 4, 0};
int __attribute__((section(".dram0.data"))) v_47_0[4] = {1, 2, 0, 4};
int __attribute__((section(".dram0.data"))) v_65[4] = {6, 4, 5, 0};
int __attribute__((section(".dram0.data"))) v_65_0[4] = {2, 0, 1, 4};
void kernel(float * aq, float * at, float * bq, float * bt, float * rq, float * rt) {
float * __restrict aq_mut = aq;
  valign align_aq;
  align_aq = PDX_LA_MXF32_PP((xb_vecMxf32 *) aq);
  float * __restrict at_mut = at;
  valign align_at;
  align_at = PDX_LA_MXF32_PP((xb_vecMxf32 *) at);
  float * __restrict bq_mut = bq;
  valign align_bq;
  align_bq = PDX_LA_MXF32_PP((xb_vecMxf32 *) bq);
  float * __restrict bt_mut = bt;
  valign align_bt;
  align_bt = PDX_LA_MXF32_PP((xb_vecMxf32 *) bt);
  float * __restrict rq_mut = rq;
  valign align_rq;
  float * __restrict rt_mut = rt;
  valign align_rt;
  xb_vecMxf32 aq_0_4;
  PDX_LAV_MXF32_XP(aq_0_4, align_aq, (xb_vecMxf32 *) aq_mut, 16);
  xb_vecMxf32 at_0_4;
  PDX_LAV_MXF32_XP(at_0_4, align_at, (xb_vecMxf32 *) at_mut, 16);
  xb_vecMxf32 bq_0_4;
  PDX_LAV_MXF32_XP(bq_0_4, align_bq, (xb_vecMxf32 *) bq_mut, 16);
  xb_vecMxf32 bt_0_4;
  PDX_LAV_MXF32_XP(bt_0_4, align_bt, (xb_vecMxf32 *) bt_mut, 16);
  float v_1 = aq[3];
  float v_2 = 1;
  float v_3_tmp[4] = {v_1, v_1, v_1, v_2};
  xb_vecMxf32 v_3 = *((xb_vecMxf32 *) v_3_tmp);
  xb_vecMxf32 v_5;
  v_5 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(bq_0_4), *((xb_vecMx32 *) v_4_0)));
  xb_vecMxf32 v_6 = PDX_MUL_MXF32(v_3, v_5);
  float v_7 = aq[0];
  float v_8 = aq[1];
  float v_9 = aq[2];
  float v_10_tmp[4] = {v_7, v_8, v_9, v_2};
  xb_vecMxf32 v_10 = *((xb_vecMxf32 *) v_10_tmp);
  xb_vecMxf32 v_12;
  v_12 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(bq_0_4), *((xb_vecMx32 *) v_11_0)));
  xb_vecMxf32 v_13 = PDX_MUL_MXF32(v_10, v_12);
  xb_vecMxf32 v_15;
  v_15 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(aq_0_4), *((xb_vecMx32 *) v_14_0)));
  xb_vecMxf32 v_17;
  v_17 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(bq_0_4), *((xb_vecMx32 *) v_16_0)));
  xb_vecMxf32 v_18 = v_13;
  PDX_MULA_MXF32(v_18, v_15, v_17);
  xb_vecMxf32 v_19 = PDX_ADD_MXF32(v_6, v_18);
  float v_20_tmp[4] = {v_2, v_2, v_2, v_7};
  xb_vecMxf32 v_20 = *((xb_vecMxf32 *) v_20_tmp);
  xb_vecMxf32 v_22;
  v_22 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(PDX_MOV_MX32_FROM_MXF32(bq_0_4), *((xb_vecMxf32 *) v_0), *((xb_vecMx32 *) v_21_0)));
  xb_vecMxf32 v_23 = PDX_MUL_MXF32(v_20, v_22);
  xb_vecMxf32 v_24 = PDX_NEG_MXF32(v_23);
  float v_25_tmp[4] = {v_2, v_2, v_2, v_8};
  xb_vecMxf32 v_25 = *((xb_vecMxf32 *) v_25_tmp);
  xb_vecMxf32 v_27;
  v_27 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(PDX_MOV_MX32_FROM_MXF32(bq_0_4), *((xb_vecMxf32 *) v_0), *((xb_vecMx32 *) v_26_0)));
  xb_vecMxf32 v_28 = PDX_MUL_MXF32(v_25, v_27);
  xb_vecMxf32 v_29 = PDX_NEG_MXF32(v_28);
  xb_vecMxf32 v_31;
  v_31 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(aq_0_4), *((xb_vecMx32 *) v_30_0)));
  xb_vecMxf32 v_33;
  v_33 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(bq_0_4), *((xb_vecMx32 *) v_32_0)));
  xb_vecMxf32 v_34 = PDX_MUL_MXF32(v_31, v_33);
  xb_vecMxf32 v_35 = PDX_NEG_MXF32(v_34);
  xb_vecMxf32 v_36 = PDX_ADD_MXF32(v_29, v_35);
  xb_vecMxf32 v_37 = PDX_ADD_MXF32(v_24, v_36);
  xb_vecMxf32 v_38 = PDX_ADD_MXF32(v_19, v_37);
  xb_vecMxf32 v_40;
  v_40 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(at_0_4), *((xb_vecMx32 *) v_4_1)));
  xb_vecMxf32 v_42;
  v_42 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(bt_0_4), *((xb_vecMx32 *) v_4_2)));
  float v_43_tmp[4] = {v_8, v_9, v_7, v_2};
  xb_vecMxf32 v_43 = *((xb_vecMxf32 *) v_43_tmp);
  float v_44 = 2;
  float v_45_tmp[4] = {v_44, v_44, v_44, v_2};
  xb_vecMxf32 v_45 = *((xb_vecMxf32 *) v_45_tmp);
  xb_vecMxf32 v_48;
  v_48 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(bt_0_4), *((xb_vecMx32 *) v_47_0)));
  xb_vecMxf32 v_49 = PDX_MUL_MXF32(v_10, v_48);
  xb_vecMxf32 v_53 = PDX_MUL_MXF32(v_43, v_42);
  xb_vecMxf32 v_54 = PDX_NEG_MXF32(v_53);
  xb_vecMxf32 v_55 = PDX_ADD_MXF32(v_49, v_54);
  xb_vecMxf32 v_56 = PDX_MUL_MXF32(v_45, v_55);
  xb_vecMxf32 v_57 = PDX_MUL_MXF32(v_43, v_56);
  float v_58_tmp[4] = {v_9, v_7, v_8, v_2};
  xb_vecMxf32 v_58 = *((xb_vecMxf32 *) v_58_tmp);
  xb_vecMxf32 v_63 = PDX_MUL_MXF32(v_58, v_42);
  xb_vecMxf32 v_66;
  v_66 = PDX_MOV_MXF32_FROM_MX32(PDX_SEL_MX32(*((xb_vecMxf32 *) v_0), PDX_MOV_MX32_FROM_MXF32(bt_0_4), *((xb_vecMx32 *) v_65_0)));
  xb_vecMxf32 v_67 = PDX_MUL_MXF32(v_10, v_66);
  xb_vecMxf32 v_68 = PDX_NEG_MXF32(v_67);
  xb_vecMxf32 v_69 = PDX_ADD_MXF32(v_63, v_68);
  xb_vecMxf32 v_70 = PDX_MUL_MXF32(v_45, v_69);
  xb_vecMxf32 v_71 = PDX_MUL_MXF32(v_58, v_70);
  xb_vecMxf32 v_72 = PDX_NEG_MXF32(v_71);
  xb_vecMxf32 v_73 = PDX_ADD_MXF32(v_57, v_72);
  xb_vecMxf32 v_79 = PDX_MUL_MXF32(v_43, v_66);
  xb_vecMxf32 v_83 = PDX_MUL_MXF32(v_58, v_48);
  xb_vecMxf32 v_84 = PDX_NEG_MXF32(v_83);
  xb_vecMxf32 v_85 = PDX_ADD_MXF32(v_79, v_84);
  xb_vecMxf32 v_86 = PDX_MUL_MXF32(v_45, v_85);
  xb_vecMxf32 v_87 = v_73;
  PDX_MULA_MXF32(v_87, v_3, v_86);
  xb_vecMxf32 v_88 = PDX_ADD_MXF32(v_42, v_87);
  xb_vecMxf32 v_89 = PDX_ADD_MXF32(v_40, v_88);
  PDX_SAV_MXF32_XP(v_38, align_rq, (xb_vecMxf32 *) rq, 16);
  PDX_SAV_MXF32_XP(v_89, align_rt, (xb_vecMxf32 *) rt, 16);
}
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if defined(__XTENSA__)
#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#endif // defined(__XTENSA__)

namespace diospyros {

#if defined(__XTENSA__)
/*
Git revision: eaa8a14

Warning: dirty git status:
cdios.py       | 17 ++++++++---------
demo/README.md |  4 +++-
2 files changed, 11 insertions(+), 10 deletions(-)

*/
int __attribute__((section(".dram0.data"))) Z[4] = {0, 0, 0, 0};
float __attribute__((section(".dram0.data"))) v_0[4] = {0.0, 0, 0, 0};
int __attribute__((section(".dram0.data"))) v_1[4] = {0, 0, 0, 0};
int __attribute__((section(".dram0.data"))) v_1_0[4] = {0, 0, 0, 0};
int __attribute__((section(".dram0.data"))) v_3[4] = {0, 1, 2, 3};
int __attribute__((section(".dram0.data"))) v_6[4] = {3, 3, 3, 3};
int __attribute__((section(".dram0.data"))) v_6_0[4] = {3, 3, 3, 3};
int __attribute__((section(".dram0.data"))) v_8[4] = {4, 5, 6, 7};
int __attribute__((section(".dram0.data"))) v_11[4] = {6, 6, 6, 6};
int __attribute__((section(".dram0.data"))) v_11_0[4] = {2, 2, 2, 2};
int __attribute__((section(".dram0.data"))) v_13[4] = {8, 9, 10, 11};
int __attribute__((section(".dram0.data"))) v_16[4] = {4, 4, 4, 4};
int __attribute__((section(".dram0.data"))) v_16_0[4] = {0, 0, 0, 0};
int __attribute__((section(".dram0.data"))) v_21[4] = {7, 7, 7, 7};
int __attribute__((section(".dram0.data"))) v_21_0[4] = {3, 3, 3, 3};
int __attribute__((section(".dram0.data"))) v_26[4] = {8, 8, 8, 8};
int __attribute__((section(".dram0.data"))) v_26_0[4] = {0, 0, 0, 0};
void transpose_and_multiply(float *a_in, float *b_in, float *c_out) {
  float *__restrict a_in_mut = a_in;
  valign align_a_in;
  align_a_in = PDX_LA_MXF32_PP((xb_vecMxf32 *)a_in);
  float *__restrict b_in_mut = b_in;
  valign align_b_in;
  align_b_in = PDX_LA_MXF32_PP((xb_vecMxf32 *)b_in);
  float *__restrict c_out_mut = c_out;
  valign align_c_out = PDX_Z_ALIGN();
  xb_vecMxf32 a_in_0_4;
  PDX_LAV_MXF32_XP(a_in_0_4, align_a_in, (xb_vecMxf32 *)a_in_mut, 16);
  xb_vecMxf32 a_in_4_8;
  PDX_LAV_MXF32_XP(a_in_4_8, align_a_in, (xb_vecMxf32 *)a_in_mut, 16);
  xb_vecMxf32 a_in_8_12;
  PDX_LAV_MXF32_XP(a_in_8_12, align_a_in, (xb_vecMxf32 *)a_in_mut, 16);
  xb_vecMxf32 b_in_0_4;
  PDX_LAV_MXF32_XP(b_in_0_4, align_b_in, (xb_vecMxf32 *)b_in_mut, 16);
  xb_vecMxf32 b_in_4_8;
  PDX_LAV_MXF32_XP(b_in_4_8, align_b_in, (xb_vecMxf32 *)b_in_mut, 16);
  xb_vecMxf32 b_in_8_12;
  PDX_LAV_MXF32_XP(b_in_8_12, align_b_in, (xb_vecMxf32 *)b_in_mut, 16);
  xb_vecMxf32 v_2;
  v_2 = PDX_MOV_MXF32_FROM_MX32(
      PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(a_in_0_4), *((xb_vecMx32 *)v_1_0)));
  xb_vecMxf32 v_4;
  v_4 = b_in_0_4;
  xb_vecMxf32 v_5 = PDX_MUL_MXF32(v_2, v_4);
  xb_vecMxf32 v_7;
  v_7 = PDX_MOV_MXF32_FROM_MX32(
      PDX_SHFL_MX32(PDX_MOV_MX32_FROM_MXF32(a_in_0_4), *((xb_vecMx32 *)v_6_0)));
  xb_vecMxf32 v_9;
  v_9 = b_in_4_8;
  xb_vecMxf32 v_10 = v_5;
  PDX_MULA_MXF32(v_10, v_7, v_9);
  xb_vecMxf32 v_12;
  v_12 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(
      PDX_MOV_MX32_FROM_MXF32(a_in_4_8), *((xb_vecMx32 *)v_11_0)));
  xb_vecMxf32 v_14;
  v_14 = b_in_8_12;
  xb_vecMxf32 v_15 = v_10;
  PDX_MULA_MXF32(v_15, v_12, v_14);
  xb_vecMxf32 v_17;
  v_17 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(
      PDX_MOV_MX32_FROM_MXF32(a_in_4_8), *((xb_vecMx32 *)v_16_0)));
  xb_vecMxf32 v_20 = PDX_MUL_MXF32(v_17, v_9);
  xb_vecMxf32 v_22;
  v_22 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(
      PDX_MOV_MX32_FROM_MXF32(a_in_4_8), *((xb_vecMx32 *)v_21_0)));
  xb_vecMxf32 v_25 = v_20;
  PDX_MULA_MXF32(v_25, v_22, v_14);
  xb_vecMxf32 v_27;
  v_27 = PDX_MOV_MXF32_FROM_MX32(PDX_SHFL_MX32(
      PDX_MOV_MX32_FROM_MXF32(a_in_8_12), *((xb_vecMx32 *)v_26_0)));
  xb_vecMxf32 v_30 = PDX_MUL_MXF32(v_27, v_14);
  PDX_SAV_MXF32_XP(v_15, align_c_out, (xb_vecMxf32 *)c_out, 16);
  PDX_SAV_MXF32_XP(v_25, align_c_out, (xb_vecMxf32 *)c_out, 16);
  PDX_SAV_MXF32_XP(v_30, align_c_out, (xb_vecMxf32 *)c_out, 16);
  PDX_SAPOS_MXF32_FP(align_c_out, (xb_vecMxf32 *)c_out);
}

#else

void transpose_and_multiply(float *a_in, float *b_in, float *c_out)  {

}

#endif // defined(__XTENSA__)

} // namespace diospyros

namespace specification {

// void matrix_multiply(float *a, float *b, float *c) {
//   for (int y = 0; y < 3; y++) {
//     for (int x = 0; x < 4; x++) {
//       c[4 * y + x] = 0;
//       for (int k = 0; k < 3; k++) {
//         c[4 * y + x] += a[3 * y + k] * b[4 * k + x];
//       }
//     }
//   }
// }

// void transpose(float *a, float *out, int n) {
//   for (int i = 0; i < n; i++) {
//     for (int j = i; j < n; j++) {
//       out[i * n + j] = a[j * n + i];
//     }
//   }
// }

// void transpose_and_multiply(float a_in[3 * 3], float b_in[3 * 4],
//                             float c_out[3 * 4]) {

//   float tmp[3 * 3];
//   transpose(a_in, tmp, 3);
//   matrix_multiply(tmp, b_in, c_out);
// }

} // namespace specification

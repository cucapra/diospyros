#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>

#include "quaternion_product.h"
#include "../../../diospyros-private/src/utils.h"

float a_q[4] __attribute__((section(".dram0.data")));
float a_t[3] __attribute__((section(".dram0.data")));
float b_q[4] __attribute__((section(".dram0.data")));
float b_t[3] __attribute__((section(".dram0.data")));
float r_q[4] __attribute__((section(".dram0.data")));
float r_t[4] __attribute__((section(".dram0.data")));
// Diospyros kernel
void kernel(float * a_q, float * a_t, float * b_q, float * b_t, /* inputs */
            float * r_q, float * r_t);                          /* outputs */


// Eigen function
SE3T quaternionProduct(SE3T &a, SE3T &b);
// // Nature functions.
// extern "C" {
// }

void eigen_kernel(float * a_q, float * a_t, float * b_q, float * b_t, /* inputs */
                  float * r_q, float * r_t) {
  Eigen::Map<Eigen::Vector4f> aq_(a_q, 4, 1);
  Eigen::Map<Eigen::Vector3f> at_(a_t, 3, 1);
  SE3T a_ = {aq_, at_};


  Eigen::Map<Eigen::Vector4f> bq_(b_q, 4, 1);
  Eigen::Map<Eigen::Vector3f> bt_(b_t, 3, 1);
  SE3T b_ = {bq_, bt_};

  SE3T c_ = quaternionProduct(a_, b_);

  memcpy (r_q, c_.quaternion.data(), sizeof(float) * 4 );
  memcpy (r_t, c_.translation.data(), sizeof(float) * 3 );
}


int main(int argc, char **argv) {

  FILE *file = fopen(OUTFILE, "w");
  if (file == NULL) file = stdout;;

  init_rand(10);

  create_random_mat(a_q, 4, 1);
  create_random_mat(a_t, 3, 1);
  create_random_mat(b_q, 4, 1);
  create_random_mat(b_t, 3, 1);

  zero_matrix(r_q, 4, 1);
  zero_matrix(r_t, 4, 1);

  print_matrix(a_q, 4, 1);
  print_matrix(a_t, 3, 1);
  print_matrix(b_q, 4, 1);
  print_matrix(b_t, 3, 1);

  int time = 0;

  // Eigen
  Eigen::Map<Eigen::Vector4f> aq_(a_q, 4, 1);
  Eigen::Map<Eigen::Vector3f> at_(a_t, 3, 1);
  SE3T a_ = {aq_, at_};


  Eigen::Map<Eigen::Vector4f> bq_(b_q, 4, 1);
  Eigen::Map<Eigen::Vector3f> bt_(b_t, 3, 1);
  SE3T b_ = {bq_, bt_};

  start_cycle_timing;
  SE3T c_ = quaternionProduct(a_, b_);
  stop_cycle_timing;

  memcpy (r_q, c_.quaternion.data(), sizeof(float) * 4 );
  memcpy (r_t, c_.translation.data(), sizeof(float) * 3 );

  // start_cycle_timing;
  // eigen_kernel(a_q, a_t, b_q, b_t, r_q, r_t);
  // stop_cycle_timing;
  time = get_time();
  print_matrix(r_q, 4, 1);
  print_matrix(r_t, 4, 1);
  printf("Eigen : %d cycles\n", time);

  zero_matrix(r_q, 4, 1);
  zero_matrix(r_t, 4, 1);

  // Diospyros
  start_cycle_timing;
  kernel(a_q, a_t, b_q, b_t, r_q, r_t);
  stop_cycle_timing;
  time = get_time();
  print_matrix(r_q, 4, 1);
  print_matrix(r_t, 4, 1);
  printf("Diospyros : %d cycles\n", time);

  return 0;
}

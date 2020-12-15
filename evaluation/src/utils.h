#ifdef __XTENSA__
#include <xtensa/sim.h>
#include <xtensa/tie/xt_pdxn.h>
#include <xtensa/tie/xt_timer.h>
#include <xtensa/xt_profiling.h>
#endif

#define ERR_TOLERANCE 0.001

// Time stamping
int start = 0, stop = 0;
int timing = 0;

#ifdef __XTENSA__

// Real time stamping on the Xtensa simulator.
#define TIME_STAMP(cyc_cnt)    \
  {                            \
    cyc_cnt = XT_RSR_CCOUNT(); \
  }

#define start_cycle_timing \
{ \
  xt_iss_switch_mode(XT_ISS_CYCLE_ACCURATE);\
  TIME_STAMP(start);\
}

#define stop_cycle_timing { \
  TIME_STAMP(stop);\
  xt_iss_switch_mode(XT_ISS_FUNCTIONAL);\
}

#else

// Fake time stamping on native targets.
#define start_cycle_timing \
    start = 0;
#define stop_cycle_timing \
    stop = 0;

#endif

inline __attribute__((gnu_inline)) int get_time() {
  return stop - start;
}

// Matrix utils
void zero_matrix(float *m, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        m[i] = 0;
    }
}

void print_matrix(float *m, int rows, int cols) {
    printf("\n");
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%f, ", m[(i * cols) + j]);
        }
        printf(";\n");
    }
}

void output_check(float *c, float *c_spec, int rows, int cols) {
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      float diff = c_spec[cols * y + x] - c[cols * y + x];
      if (fabs(diff) >= ERR_TOLERANCE) {
        printf("%f\n", diff);
        printf("mismatch at (%d,%d) reference = %f, actual = %f, error = %f \n", y, x, c_spec[cols * y + x], c[cols * y + x], diff);
        exit(1);
      }
    }
  }
}

void output_check_abs(float *c, float *c_spec, int rows, int cols) {
  for (int y = 0; y < rows; y++) {
    for (int x = 0; x < cols; x++) {
      float diff = fabs(c_spec[cols * y + x]) - fabs(c[cols * y + x]);
      if (fabs(diff) >= ERR_TOLERANCE) {
        printf("%f\n", diff);
        printf("mismatch at (%d,%d) reference = %f, actual = %f, error = %f \n", y, x, c_spec[cols * y + x], c[cols * y + x], diff);
        exit(1);
      }
    }
  }
}

// Random number generation
#define PHI  0x9e3779b9
#define ABS(x)  (((x) > 0) ? x : -(x))

static int32_t Q[4096], _c = 362436;

void init_rand(uint32_t x) {
  int i;

  Q[0] = x;
  Q[1] = x + PHI;
  Q[2] = x + PHI + PHI;

  for (i = 3; i < 4096; i++) {
    Q[i] = Q[i - 3] ^ Q[i - 2] ^ PHI ^ i;
  }
}

uint32_t rand_cmwc(void) {
  uint64_t t, a = 18782LL;
  static uint32_t i = 4095;
  int32_t x, r = 0xfffffffe;
  i = (i + 1) & 4095;
  t = a * Q[i] + _c;
  _c = (t >> 32);
  x = (uint32_t) (t + _c);
  if (x < _c) {
    x++;
    _c++;
  }
  return(ABS(Q[i] = r - x));
}

void create_random_mat(float *a, int row, int col) {
  int k;
  for (k = 0; k < row * col; k++) {
    *a++ = (float) (rand_cmwc() % 100) / (float) 10.0;
  }
  return;
}

// #include <math.h>

float pow(float base, float exponent);
float sqrt(float x);

#define SIZE 4

void vec_norm(float a_in[SIZE], float b_out[1]) {
  float sum = 0;
  for (int i = 0; i < SIZE; i++) {
    sum += pow(a_in[i], 2);
  }
  b_out[0] = sqrt(sum);
}
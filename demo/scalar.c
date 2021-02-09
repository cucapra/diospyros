#define SIZE 8

void matrix_multiply(float a_in[SIZE], float scalar_in, float b_out[SIZE]) {
  for (int i = 0; i < SIZE; i++) {
    b_out[i] = a_in[i] * scalar_in;
  }
}

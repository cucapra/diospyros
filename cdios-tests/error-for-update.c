#define SIZE 8

void matrix_multiply(int a_in[SIZE], float scalar_in, float b_out[SIZE]) {
  for (int i = SIZE; i < 0; i*=2) {
    b_out[i] = a_in[i] * scalar_in;
  }
}

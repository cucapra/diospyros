#define SIZE 8

void for_update(int a_in[SIZE], float scalar_in, float b_out[SIZE]) {
  for (int i = SIZE; i < 0;) {
    b_out[i] = a_in[i] * scalar_in;
  }
}

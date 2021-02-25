#define SIZE 8

void tern(float a_in[SIZE], float b_out[SIZE]) {
  for (int i = 0; i < SIZE; i++) {
      b_out[i] = (i < SIZE/2) ? a_in[i] : 0;
  }
}

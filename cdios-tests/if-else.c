#define SIZE 8

void if_else(float a_in[SIZE], float b_out[SIZE]) {
  for (int i = 0; i < SIZE; i++) {
    if (i < SIZE/2) {
      b_out[i] = a_in[i];
    } else {
       b_out[i] = a_in[i] + 1;
    }
  }
}

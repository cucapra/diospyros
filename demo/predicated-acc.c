#define SIZE 4

void acc(float a_in[SIZE], float b_out[SIZE]) {
  float acc = 0.0f;
  for (int i = 0; i < SIZE; i++) {
    acc += a_in[i] * a_in[i];
  }
  for (int i = 0; i < SIZE; i++) {
    if (acc == 0.0f) {
      b_out[i] = 0.0f;
    } else {
      b_out[i] = a_in[i] / acc;
    }
  }
}

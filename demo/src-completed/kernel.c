#define A_SIZE 3
#define B_ROWS 3
#define B_COLS 4

// Naive hard-coded size implementation
void matrix_multiply(float *a, float *b, float *c) {
  for (int y = 0; y < A_SIZE; y++) {
   for (int x = 0; x < B_COLS; x++) {
     c[B_COLS * y + x] = 0;
     for (int k = 0; k < A_SIZE; k++) {
       c[B_COLS * y + x] += a[A_SIZE * y + k] * b[B_COLS * k + x];
     }
   }
  }
}

// Naive implementation
void transpose(float *a, float *out, int n) {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      out[i*n + j] = a[j*n + i];
    }
  }
}

void transpose_and_multiply(float a_in[A_SIZE * A_SIZE],
                            float b_in[B_ROWS * B_COLS],
                            float c_out[A_SIZE * B_COLS]) {

  float tmp[A_SIZE * A_SIZE];
  transpose(a_in, tmp, A_SIZE);
  matrix_multiply(tmp, b_in, c_out);
}
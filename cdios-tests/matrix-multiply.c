#define A_ROWS 2
#define A_COLS 2
#define B_COLS 2

void matrix_multiply(float a_in[A_ROWS*A_COLS], float b_in[A_COLS*B_COLS], float c_out[A_ROWS*B_COLS]) {
  for (int y = 0; y < A_ROWS; y++) {
    for (int x = 0; x < B_COLS; x++) {
      c_out[B_COLS * y + x] = 0;
      for (int k = 0; k < A_COLS; k++) {
        c_out[B_COLS * y + x] += a_in[A_COLS * y + k] * b_in[B_COLS * k + x];
      }
    }
  }
}

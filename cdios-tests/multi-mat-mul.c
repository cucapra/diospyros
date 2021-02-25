#define ROWS 3
#define COLS 3

void matrix_multiply_3x3(float a[ROWS * COLS], float b[COLS * COLS],
                         float c[ROWS * COLS]) {
  for (int i = 0; i < ROWS; i++) {
    for (int j = 0; j < COLS; j++) {
      c[j * ROWS + i] = 0;

      for (int k = 0; k < COLS; k++) {
        c[j * ROWS + i] += a[k * ROWS + i] * b[j * COLS + k];
      }
    }
  }
}

void multimatrix_multiply(float a_in[ROWS * COLS], float b_in[ROWS * COLS],
                          float c_in[ROWS * COLS], float d_out[ROWS * COLS]) {

  float ab[ROWS * COLS];
  matrix_multiply_3x3(a_in, b_in, ab);
  matrix_multiply_3x3(ab, c_in, d_out);
}
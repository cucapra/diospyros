
// Naive hard-coded size
void matrix_multiply(float *a_in, float *b_in, float *c_out,
  int a_rows_size, int a_cols_size, int b_cols_size) {
  for (int y = 0; y < a_rows_size; y++) {
    for (int x = 0; x < b_cols_size; x++) {
      c_out[b_cols_size * y + x] = 0;
      for (int k = 0; k < a_cols_size; k++) {
        c_out[b_cols_size * y + x] += a_in[a_cols_size * y + k] * b_in[b_cols_size * k + x];
      }
    }
  }
}

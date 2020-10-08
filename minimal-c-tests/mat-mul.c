// TODO: how do we associate sizes with inputs? Assume upper bound?
// Idea from Rachit: float a_in[M][N], then we preprocess to add #defines before
// Thought from Vincent: look into whether sizes can be a template parameter

// Thought: assume top level function is the last function written
// Or, force it to be called KERNEL, use a macro, etc
void matrix_multiply(float *a_in, float *b_in, float *c_out,
    int row1_size, int col1_size, int col2_size) {
  for (int y = 0; y < row1_size; y++) {
    for (int x = 0; x < col2_size; x++) {
      c_out[col2_size * y + x] = 0;
      for (int k = 0; k < col1_size; k++) {
        c_out[col2_size * y + x] += a_in[col1_size * y + k] * b_in[col2_size * k + x];
      }
    }
  }
}
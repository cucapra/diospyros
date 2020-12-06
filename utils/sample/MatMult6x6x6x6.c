/*!

  Specification file of the target kernel to be consumed by the Diosypros tool

*/

#define A_ROWS 6
#define A_COLS 6
#define B_COLS 6

void matrix_multiply(
    float a_in[A_ROWS * A_COLS],
    float b_in[A_COLS * B_COLS],
    float c_out[A_ROWS * B_COLS]) {
  for (int i = 0; i < A_ROWS; i++) {
    for (int j = 0; j < B_COLS; j++) {
      c_out[j * A_ROWS + i] = 0;

      for (int k = 0; k < A_COLS; k++) {
        c_out[j * A_ROWS + i] += a_in[k * A_ROWS + i] * b_in[j * A_COLS + k];
      }
    }
  }
}

#define SIZE 8

void break_w_test(float a_in[SIZE], float scalar_in, float b_out[SIZE])
{
  int i = SIZE - 1;
  while (i >= 0)
  {
    if (i < SIZE/2) break;
    b_out[i] = a_in[i] * scalar_in;
    i -= 1;
  }
  b_out[0] = scalar_in;
}
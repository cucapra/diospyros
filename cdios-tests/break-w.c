#define SIZE 8

void break_w_test(float a_in[SIZE], float scalar_in, float b_out[SIZE])
{
  int i = 0;
  while (i < SIZE)
  {
    if (i >= SIZE/2) break;
    b_out[i] = a_in[i] * scalar_in;
    i += 1;
  }
  b_out[0] = scalar_in;
}
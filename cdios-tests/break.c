#define SIZE 8

void break_test(float a_in[SIZE], float scalar_in, float b_out[SIZE])
{
  for (int i = SIZE - 1; i >= 0; i--)
  {
    if (i < SIZE/2) break;
    b_out[i] = a_in[i] * scalar_in;
  }
  b_out[0] = scalar_in;
}

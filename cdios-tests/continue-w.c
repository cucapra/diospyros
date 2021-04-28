#define SIZE 8

void continue_w_test(float a_in[SIZE], float scalar_in, float b_out[SIZE])
{
  int i = 0;
  while (i < SIZE)
  {
    if (i < SIZE/2)
    {
      i += 1;
      continue;
    }
    b_out[i] = a_in[i] * scalar_in;
    i += 1;
  }
}

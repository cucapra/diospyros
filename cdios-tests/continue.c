#define SIZE 8

void continue_test(float a_in[SIZE], float scalar_in, float b_out[SIZE])
{
  for (int i = 0; i < SIZE; i++)
  {
    if (i < SIZE/2) continue;
    b_out[i] = a_in[i] * scalar_in;
  }
}
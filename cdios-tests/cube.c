#define SIZE 8

void cube(float a_in[SIZE], float b_out[SIZE])
{
  for (int i = 0; i < SIZE; i++)
  {
    b_out[i] = powf(a_in[i], 3);
  }
}

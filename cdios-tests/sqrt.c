#define SIZE 8

void vsqrt(float a_in[SIZE], float b_out[SIZE]){
  for (int i = 0; i < SIZE; i++){
    b_out[i] = sqrt(a_in[i]);
  }
}

#include <stdio.h>

int a_in[] = {1, 2, 3, 4};
int b_in[] = {5, 6, 7, 8};

int main(int argc, char **argv) {
//  return argc + 5;
  int c_out[4];
  c_out[0] = a_in[0] + b_in[0];
  c_out[1] = a_in[1] + b_in[1];
  c_out[2] = a_in[2] + b_in[2];
  c_out[3] = a_in[3] + b_in[3];
  printf("first: %i\n", c_out[0]);
  printf("second: %i\n", c_out[1]);
  printf("third: %i\n", c_out[2]);
  printf("fourth: %i\n", c_out[3]);
  return 0;
}

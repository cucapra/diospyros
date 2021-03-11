

void tern(float a_in[8], float b_out[8]) {
  for (int i = 0; i < 8; i++) {
      b_out[i] = (i < 8/2) ? a_in[i] : 0;
  }
}

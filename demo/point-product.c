void cross_product(float lhs[3], float rhs[3], float result[3]) {
  result[0] = lhs[1] * rhs[2] - lhs[2] * rhs[1];
  result[1] = lhs[2] * rhs[0] - lhs[0] * rhs[2];
  result[2] = lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

/*
  Computes the point product
*/
void point_product(float q_in[4], float p_in[4], float result_out[4]) {
  // float qvec[3] = {q_in[0], q_in[1], q_in[2]};

  float qvec[3];

  qvec[0] = q_in[0];
  qvec[1] = q_in[1];
  qvec[2] = q_in[2];

  float uv[3];
  cross_product(qvec, p_in, uv);

  for (int i = 0; i < 3; i++) {
    uv[i] = uv[i] * 2;
  }
  float qxuv[3];
  cross_product(qvec, uv, qxuv);

  for (int i = 0; i < 3; i++) {
    result_out[i] = p_in[i] + q_in[3]*uv[i] + qxuv[i];
  }
}
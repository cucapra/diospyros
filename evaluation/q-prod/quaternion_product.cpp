#include <Eigen/Core>

#include <quaternion_product.h>

/*
  Assume quaternion data format is (x, y, z, w) and translational format is (x,
  y, z)

  Verifies against Eigen cross product implementation
*/

Eigen::Vector<float, 3> crossProduct(Eigen::Vector<float, 3> lhs,
                                     Eigen::Vector<float, 3> rhs) {

  Eigen::Vector<float, 3> result(
      lhs.coeff(1) * rhs.coeff(2) - lhs.coeff(2) * rhs.coeff(1),
      lhs.coeff(2) * rhs.coeff(0) - lhs.coeff(0) * rhs.coeff(2),
      lhs.coeff(0) * rhs.coeff(1) - lhs.coeff(1) * rhs.coeff(0));
  return result;
}

/*
  Computes the point product
*/
Eigen::Vector<float, 3> pointProduct(Eigen::Vector<float, 4> &q,
                                     Eigen::Vector<float, 3> &p) {
  Eigen::Vector<float, 3> qvec(q(0), q(1), q(2));

  Eigen::Vector<float, 3> uv = crossProduct(qvec, p); // qvec.cross(p);
  for (int i = 0; i < 3; i++) {
    uv(i) = uv(i) * 2;
  }
  Eigen::Vector<float, 3> qxuv = crossProduct(qvec, uv); // qvec.cross(uv);

  Eigen::Vector<float, 3> result;
  result = p + (q(3) * uv) + qxuv;

  return result;
}

/*
  Takes two quaternions and multiplies them together

  Verified against the SE3 product in Sophus
*/
SE3T quaternionProduct(SE3T &a, SE3T &b) {
  Eigen::Vector<float, 3> resultTranslation;
  Eigen::Vector<float, 4> resultQuaternion;

  Eigen::Vector<float, 4> aq = a.quaternion;
  Eigen::Vector<float, 4> bq = b.quaternion;

  // Hamilton product
  resultQuaternion(3) =
      aq(3) * bq(3) - aq(0) * bq(0) - aq(1) * bq(1) - aq(2) * bq(2);
  resultQuaternion(0) =
      aq(3) * bq(0) + aq(0) * bq(3) + aq(1) * bq(2) - aq(2) * bq(1);
  resultQuaternion(1) =
      aq(3) * bq(1) + aq(1) * bq(3) + aq(2) * bq(0) - aq(0) * bq(2);
  resultQuaternion(2) =
      aq(3) * bq(2) + aq(2) * bq(3) + aq(0) * bq(1) - aq(1) * bq(0);

  Eigen::Vector<float, 3> r = pointProduct(a.quaternion, b.translation);

  resultTranslation = a.translation + r;

  SE3T result = {resultQuaternion, resultTranslation};
  return result;
}

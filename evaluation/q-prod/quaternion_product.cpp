#include <Eigen/Core>

#include "quaternion_product.h"

/*
  Assume quaternion data format is (x, y, z, w) and translational format is (x,
  y, z)

  Verifies against Eigen cross product implementation
*/

__attribute__((always_inline)) Eigen::Vector3f crossProduct(Eigen::Vector3f lhs,
                                     Eigen::Vector3f rhs) {

  Eigen::Vector3f result(
      lhs.coeff(1) * rhs.coeff(2) - lhs.coeff(2) * rhs.coeff(1),
      lhs.coeff(2) * rhs.coeff(0) - lhs.coeff(0) * rhs.coeff(2),
      lhs.coeff(0) * rhs.coeff(1) - lhs.coeff(1) * rhs.coeff(0));
  return result;
}

/*
  Computes the point product
*/
__attribute__((always_inline)) Eigen::Vector3f pointProduct(Eigen::Vector4f &q,
                                     Eigen::Vector3f &p) {
  Eigen::Vector3f qvec(q(0), q(1), q(2));

  Eigen::Vector3f uv = crossProduct(qvec, p); // qvec.cross(p);
  for (int i = 0; i < 3; i++) {
    uv(i) = uv(i) * 2;
  }
  Eigen::Vector3f qxuv = crossProduct(qvec, uv); // qvec.cross(uv);

  Eigen::Vector3f result;
  result = p + (q(3) * uv) + qxuv;

  return result;
}

/*
  Takes two quaternions and multiplies them together

  Verified against the SE3 product in Sophus
*/
SE3T quaternionProduct(SE3T &a, SE3T &b) {
  Eigen::Vector3f resultTranslation;
  Eigen::Vector4f resultQuaternion;

  Eigen::Vector4f aq = a.quaternion;
  Eigen::Vector4f bq = b.quaternion;

  // Hamilton product
  resultQuaternion(3) =
      aq(3) * bq(3) - aq(0) * bq(0) - aq(1) * bq(1) - aq(2) * bq(2);
  resultQuaternion(0) =
      aq(3) * bq(0) + aq(0) * bq(3) + aq(1) * bq(2) - aq(2) * bq(1);
  resultQuaternion(1) =
      aq(3) * bq(1) + aq(1) * bq(3) + aq(2) * bq(0) - aq(0) * bq(2);
  resultQuaternion(2) =
      aq(3) * bq(2) + aq(2) * bq(3) + aq(0) * bq(1) - aq(1) * bq(0);

  Eigen::Vector3f r = pointProduct(a.quaternion, b.translation);

  resultTranslation = a.translation + r;

  SE3T result = {resultQuaternion, resultTranslation};
  return result;
}

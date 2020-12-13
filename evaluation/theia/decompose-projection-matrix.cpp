#include <iostream>
#include <Eigen/Core>
#include <Eigen/Dense>
#include "../src/utils.h"

// Use either Eigen or Diospyros RQ routine.
#ifdef DIOS
#include "dios_rq_decomposition.h"
static const char *BACKEND = "Dios";
#else
#include "rq_decomposition.h"
static const char *BACKEND = "Eigen";
#endif

using namespace theia;
using Eigen::Matrix3f;
using Eigen::Vector3f;

// Copied from `util.cc` in Theia! --AS
// Projects a 3x3 matrix to the rotation matrix in SO3 space with the closest
// Frobenius norm. For a matrix with an SVD decomposition M = USV, the nearest
// rotation matrix is R = UV'.
Matrix3f ProjectToRotationMatrix(const Matrix3f& matrix) {
  Eigen::JacobiSVD<Matrix3f> svd(matrix,
                                 Eigen::ComputeFullU | Eigen::ComputeFullV);
  Matrix3f rotation_mat = svd.matrixU() * (svd.matrixV().transpose());

  // The above projection will give a matrix with a determinant +1 or -1. Valid
  // rotation matrices have a determinant of +1.
  if (rotation_mat.determinant() < 0) {
    rotation_mat *= -1.0;
  }

  return rotation_mat;
}

// Used as the projection matrix type.
typedef Eigen::Matrix<float, 3, 4> Matrix3x4f;

// Generate a calibration matrix from some parameters.
void IntrinsicsToCalibrationMatrix(const float focal_length,
                                   const float skew,
                                   const float aspect_ratio,
                                   const float principal_point_x,
                                   const float principal_point_y,
                                   Matrix3f* calibration_matrix) {
  *calibration_matrix <<
      focal_length, skew, principal_point_x,
      0, focal_length * aspect_ratio, principal_point_y,
      0, 0, 1.0;
}

// Generate a projection matrix from a rotation and position.
bool ComposeProjectionMatrix(const Matrix3f& calibration_matrix,
                             const Vector3f& rotation,
                             const Vector3f& position,
                             Matrix3x4f* pmatrix) {
  const double rotation_angle = rotation.norm();
  if (rotation_angle == 0) {
    pmatrix->block<3, 3>(0, 0) = Matrix3f::Identity();
  } else {
    pmatrix->block<3, 3>(0, 0) = Eigen::AngleAxisf(
        rotation_angle, rotation / rotation_angle).toRotationMatrix();
  }

  pmatrix->col(3) = - (pmatrix->block<3, 3>(0, 0) *  position);
  *pmatrix = calibration_matrix * (*pmatrix);
  return true;
}

bool DecomposeProjectionMatrix(const Matrix3x4f pmatrix,
                               Eigen::Matrix3f* calibration_matrix,
                               Eigen::Vector3f* rotation,
                               Eigen::Vector3f* position) {

#ifdef DIOS
  RQDecomposition rq(pmatrix.block<3, 3>(0, 0));
#else
  RQDecomposition<Eigen::Matrix3f> rq(pmatrix.block<3, 3>(0, 0));
#endif

  Eigen::Matrix3f rotation_matrix = ProjectToRotationMatrix(rq.matrixQ());

  const float k_det = rq.matrixR().determinant();
  if (k_det == 0) {
    return false;
  }

  Eigen::Matrix3f& kmatrix = *calibration_matrix;
  if (k_det > 0) {
    kmatrix = rq.matrixR();
  } else {
    kmatrix = -rq.matrixR();
  }

  // Fix the matrix such that all internal parameters are greater than 0.
  for (int i = 0; i < 3; ++i) {
    if (kmatrix(i, i) < 0) {
      kmatrix.col(i) *= -1.0;
      rotation_matrix.row(i) *= -1.0;
    }
  }

  // Solve for t.
  const Eigen::Vector3f t =
      kmatrix.triangularView<Eigen::Upper>().solve(pmatrix.col(3));

  // c = - R' * t, and flip the sign according to k_det;
  if (k_det > 0) {
    *position = - rotation_matrix.transpose() * t;
  } else {
    *position = rotation_matrix.transpose() * t;
  }

  const Eigen::AngleAxisf rotation_aa(rotation_matrix);
  *rotation = rotation_aa.angle() * rotation_aa.axis();

  return true;
}

int main() {
  int time = 0;

  // Create a projection matrix from "raw materials."
  Matrix3f in_calibration;
  IntrinsicsToCalibrationMatrix(0.3, 0.2, 0.4, 0.5, 0.6, &in_calibration);
  Vector3f in_rotation;
  in_rotation << 0.3, 0.7, 0.2;
  Vector3f in_position;
  in_position << 0.9, 0.1, 0.6;
  Matrix3x4f random_pmatrix;
  ComposeProjectionMatrix(in_calibration, in_rotation, in_position, &random_pmatrix);

  Matrix3f calibration_matrix;
  Vector3f rotation, position;

  start_cycle_timing;
  bool success = DecomposeProjectionMatrix(random_pmatrix,
                                           &calibration_matrix,
                                           &rotation,
                                           &position);
  stop_cycle_timing;
  time = get_time();
  printf("DecomposeProjectionMatrix - %s: %d cycles\n", BACKEND, time);

  std::cout << "Input:" << std::endl << random_pmatrix << std::endl;
  std::cout << "Rotation:" << std::endl << rotation << std::endl;
  std::cout << "Position:" << std::endl << position << std::endl;
  return 0;
}

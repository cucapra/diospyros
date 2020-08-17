#include <Eigen>

using namespace Eigen;

void DistortPoint(const Vector3d& point_in_camera, const double focal_length,
                  const double radial_distortion, Vector2d& distorted_point);

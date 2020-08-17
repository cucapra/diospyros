#include <Eigen>
#include <fisheye_distortion.h>

/*

  Fisheye distortion kernel ubenchmark

  Derived from https://github.com/sweeneychris/floatheiaSfM/blob/master/src/theia/sfm/camera/fisheye_camera_model.h

*/

void FisheyeDistortPoint(Eigen::Vector<float, 9> intrinsic_parameters, Eigen::Vector<float, 3> undistorted_point, Eigen::Vector<float, 3> & distorted_point) {
  // static const float kVerySmallNumber = float(1e-8);
  const float& radial_distortion1 =
      intrinsic_parameters[RADIAL_DISTORTION_1];
  const float& radial_distortion2 =
      intrinsic_parameters[RADIAL_DISTORTION_2];
  const float& radial_distortion3 =
      intrinsic_parameters[RADIAL_DISTORTION_3];
  const float& radial_distortion4 =
      intrinsic_parameters[RADIAL_DISTORTION_4];

  const float r_sq = undistorted_point[0] * undistorted_point[0] +
                 undistorted_point[1] * undistorted_point[1];

  // Tool currently can't handle this check. Check is not common case anyways.
  // if (r_sq < kVerySmallNumber) {
  //   distorted_point[0] = undistorted_point[0];
  //   distorted_point[1] = undistorted_point[1];
  //   return;
  // }

  const float r_numerator = std::sqrt(r_sq);
  // Using atan2 should be more stable than dividing by the denominator for
  // small z-values (i.e. viewing angles approaching 180 deg FOV).
  const float theta = std::atan2(r_numerator, std::abs(undistorted_point[2]));
  const float theta_sq = theta * theta;
  const float theta_d =
      theta * (1.0 + radial_distortion1 * theta_sq +
               radial_distortion2 * theta_sq * theta_sq +
               radial_distortion3 * theta_sq * theta_sq * theta_sq +
               radial_distortion4 * theta_sq * theta_sq * theta_sq * theta_sq);

  distorted_point[0] = theta_d * undistorted_point[0] / r_numerator;
  distorted_point[1] = theta_d * undistorted_point[1] / r_numerator;

  if (undistorted_point[2] < 0.0f) {
    distorted_point[0] = -distorted_point[0];
    distorted_point[1] = -distorted_point[1];
  }
}


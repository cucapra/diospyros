#include <Eigen>

/*

  Point distortion logic for six point radial distortion kernel

  https://github.com/sweeneychris/TheiaSfM/blob/master/src/theia/sfm/pose/six_point_radial_distortion_homography.cc

*/

using Eigen::Matrix;
using Eigen::MatrixXd;
using Eigen::Vector2d;
using Eigen::Vector3d;
using Vector6d = Eigen::Matrix<double, 6, 1>;
using Array51d = Eigen::Array<double, 5, 1>;
using Matrix68d = Eigen::Matrix<double, 6, 8>;
using Matrix62d = Eigen::Matrix<double, 6, 2>;
using Matrix65d = Eigen::Matrix<double, 6, 5>;
using Eigen::Matrix3d;

// Some helper functions
void DistortPoint(const Vector3d& point_in_camera, const double focal_length,
                  const double radial_distortion, Vector2d& distorted_point) {
    Vector2d point_in_cam_persp_div;
    point_in_cam_persp_div[0] =
        focal_length * point_in_camera[0] / point_in_camera[2];
    point_in_cam_persp_div[1] =
        focal_length * point_in_camera[1] / point_in_camera[2];

    // see also division_undistortion_camera_model.h
    const double r_u_sq = point_in_cam_persp_div.dot(point_in_cam_persp_div);

    const double denom = 2.0 * radial_distortion * r_u_sq;
    const double inner_sqrt = 1.0 - 4.0 * radial_distortion * r_u_sq;

    // remove floating point division by zero check
    const double scale = (1.0 - std::sqrt(inner_sqrt)) / denom;
    distorted_point = point_in_cam_persp_div * scale;

    // If the denominator is nearly zero then we can evaluate the distorted
    // coordinates as k or r_u^2 goes to zero. Both evaluate to the identity.
    // if (std::abs(denom) < std::numeric_limits<double>::epsilon() ||
    //     inner_sqrt < 0.0) {
    //   distorted_point = point_in_cam_persp_div;
    // } else {
    //   const double scale = (1.0 - std::sqrt(inner_sqrt)) / denom;
    //   distorted_point = point_in_cam_persp_div * scale;
    // }
}

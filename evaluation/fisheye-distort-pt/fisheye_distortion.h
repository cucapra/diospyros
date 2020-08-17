#include <Eigen>

/*

  Fisheye distortion kernel

  Derived from
  https://github.com/sweeneychris/floatheiaSfM/blob/master/src/theia/sfm/camera/fisheye_camera_model.h

*/

enum InternalParametersIndex {
    FOCAL_LENGTH = 0,
    ASPECT_RATIO = 1,
    SKEW = 2,
    PRINCIPAL_POINT_X = 3,
    PRINCIPAL_POINT_Y = 4,
    RADIAL_DISTORTION_1 = 5,
    RADIAL_DISTORTION_2 = 6,
    RADIAL_DISTORTION_3 = 7,
    RADIAL_DISTORTION_4 = 8,
};

void FisheyeDistortPoint(Eigen::Vector<float, 9> intrinsic_parameters,
                         Eigen::Vector<float, 3> undistorted_point,
                         Eigen::Vector<float, 3>& distorted_point);

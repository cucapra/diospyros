#include <Eigen>
#include <gtest/gtest.h>
#include <fisheye_distortion.h>
#include <random>

TEST(FisheyeDistortionTest, distortionTest) {

  std::mt19937 gen;
  std::uniform_real_distribution<> dist;

  gen = std::mt19937(0);
  dist = std::uniform_real_distribution<>(-1.0f, 1.0f);

  Eigen::Vector<float, 9> intrinsic_parameters;

  // in reality these parameters need to be set properly but for benchmarking this is not necessary
  intrinsic_parameters << dist(gen), dist(gen), dist(gen), dist(gen), dist(gen), dist(gen), dist(gen), dist(gen), dist(gen);
  Eigen::Vector<float, 3> undistorted_point(dist(gen), dist(gen), dist(gen));
  Eigen::Vector<float, 3> distorted_point;


  FisheyeDistortPoint(intrinsic_parameters, undistorted_point, distorted_point);
}

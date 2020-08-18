#include <Eigen>
#include <gtest/gtest.h>
#include <distortion.h>
#include <random>


TEST(DistortionTest, distortionTest) {

  std::mt19937 gen;
  std::uniform_real_distribution<> dist;

  gen = std::mt19937(0);
  dist = std::uniform_real_distribution<>(-1.0f, 1.0f);

  Eigen::Vector3d point_in_camera(dist(gen), dist(gen), dist(gen));
  double focal_length = dist(gen);
  double radial_distortion = dist(gen);
  Eigen::Vector2d distorted_point;

  DistortPoint(point_in_camera, focal_length, radial_distortion, distorted_point);
}

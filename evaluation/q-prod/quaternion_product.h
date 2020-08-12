#pragma once

#include <Eigen/Core>
#include <Eigen/Dense>

typedef struct {
  Eigen::Vector4f quaternion;
  Eigen::Vector3f translation;
} SE3T;

Eigen::Vector3f crossProduct(Eigen::Vector3f lhs, Eigen::Vector3f rhs);

Eigen::Vector3f pointProduct(Eigen::Vector4f &q, Eigen::Vector3f &p);

SE3T quaternionProduct(SE3T &a, SE3T &b);

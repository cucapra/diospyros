#pragma once

#include <Eigen>

typedef struct {
  Eigen::Vector<float, 4> quaternion;
  Eigen::Vector<float, 3> translation;
} SE3T;

Eigen::Vector<float, 3> crossProduct(Eigen::Vector<float, 3> lhs,
                                     Eigen::Vector<float, 3> rhs);

Eigen::Vector<float, 3> pointProduct(Eigen::Vector<float, 4> &q,
                                     Eigen::Vector<float, 3> &p);

SE3T quaternionProduct(SE3T &a, SE3T &b);

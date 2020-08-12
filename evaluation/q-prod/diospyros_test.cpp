#include <gtest/gtest.h>
#include <Eigen/Core>
#include <sophus/se3.hpp>

#include <determinant4x4.h>
#include <quaternion_product.h>
#include <random>

/*
  Test quaternion product utlity module
*/
TEST(DiospyrosTest, crossProductTest) {
    Eigen::Vector<float, 3> lhs(1, 2, 3);
    Eigen::Vector<float, 3> rhs(-1, 4, 6);

    Eigen::Vector<float, 3> result = crossProduct(lhs, rhs);

    auto expected = lhs.cross(rhs);

    EXPECT_EQ(expected(0), result(0));
    EXPECT_EQ(expected(1), result(1));
    EXPECT_EQ(expected(2), result(2));
}

TEST(DiospyrosTest, quaternionTest) {
    std::mt19937 gen;
    std::uniform_real_distribution<> dist;

    gen = std::mt19937(0);
    dist = std::uniform_real_distribution<>(-1.0f, 1.0f);

    ::Eigen::Quaternion<float> aq = ::Eigen::Quaternion<float>::UnitRandom();
    ::Eigen::Vector3f at(dist(gen), dist(gen), dist(gen));
    Sophus::SE3<float> a(aq, at);

    ::Eigen::Quaternion<float> bq = ::Eigen::Quaternion<float>::UnitRandom();
    ::Eigen::Vector3f bt(dist(gen), dist(gen), dist(gen));
    Sophus::SE3<float> b(bq, bt);

    Sophus::SE3<float> c = a * b;

    Eigen::Vector<float, 4> aq_(aq.x(), aq.y(), aq.z(), aq.w());
    Eigen::Vector<float, 3> at_(at(0), at(1), at(2));
    SE3T a_ = {aq_, at_};

    Eigen::Vector<float, 4> bq_(bq.x(), bq.y(), bq.z(), bq.w());
    Eigen::Vector<float, 3> bt_(bt(0), bt(1), bt(2));
    SE3T b_ = {bq_, bt_};

    SE3T c_ = quaternionProduct(a_, b_);

    auto eq = c.unit_quaternion();
    auto et = c.translation();

    auto rq = c_.quaternion;
    auto rt = c_.translation;

    EXPECT_NEAR(eq.w(), rq(3), 1E-5);
    EXPECT_NEAR(eq.x(), rq(0), 1E-5);
    EXPECT_NEAR(eq.y(), rq(1), 1E-5);
    EXPECT_NEAR(eq.z(), rq(2), 1E-5);

    EXPECT_NEAR(et(0), rt(0), 1E-5);
    EXPECT_NEAR(et(1), rt(1), 1E-5);
    EXPECT_NEAR(et(2), rt(2), 1E-5);
}

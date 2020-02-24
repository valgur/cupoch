#include "cupoch/geometry/rgbdimage.h"
#include "cupoch/odometry/rgbdodometry_jacobian.h"
#include "tests/odometry/odometry_tools.h"
#include "tests/test_utility/unit_test.h"

using namespace Eigen;
using namespace odometry_tools;
using namespace cupoch;
using namespace unit_test;

TEST(RGBDOdometryJacobianFromHybridTerm, ComputeJacobianAndResidual) {
    thrust::host_vector<Vector6f> ref_J_r(20);
    ref_J_r[0] << -0.216112, 0.111107, -0.007304, 0.030973, 0.046549, -0.208322;
    ref_J_r[1] << -2.459541, 1.263714, -0.080521, 0.240151, 0.312196, -2.435808;
    ref_J_r[2] << -0.060466, 0.025090, 0.003530, 0.005430, 0.023047, -0.070798;
    ref_J_r[3] << -1.877940, 0.851610, -0.091986, 0.277592, 0.360869, -2.326225;
    ref_J_r[4] << -0.042189, 0.021825, 0.005357, 0.006665, 0.021429, -0.034813;
    ref_J_r[5] << -1.308323, 0.819180, -0.028226, 0.163584, 0.212659, -1.410552;
    ref_J_r[6] << -0.039724, 0.021125, -0.003330, 0.017233, 0.025900, -0.041265;
    ref_J_r[7] << -0.897927, 0.443454, -0.033797, 0.133618, 0.173703, -1.270796;
    ref_J_r[8] << -0.022855, 0.035309, 0.018766, 0.013057, 0.026204, -0.033402;
    ref_J_r[9] << -0.474482, 1.240340, 0.141499, 0.168766, 0.219396, -1.357249;
    ref_J_r[10] << -0.002159, 0.006075, -0.000731, 0.003427, 0.000730,
            -0.004052;
    ref_J_r[11] << -0.521278, 1.004238, 0.055928, 0.080032, 0.104042, -1.122217;
    ref_J_r[12] << -0.008417, 0.008791, -0.004989, 0.007167, 0.001957,
            -0.008644;
    ref_J_r[13] << -1.371627, 0.860506, -0.031899, 0.184870, 0.240331,
            -1.466072;
    ref_J_r[14] << -0.060466, 0.025090, 0.003530, 0.005430, 0.023047, -0.070798;
    ref_J_r[15] << -1.877940, 0.851610, -0.091986, 0.277592, 0.360869,
            -2.326225;
    ref_J_r[16] << -0.372166, 0.318252, 0.034305, 0.020795, 0.066858, -0.394653;
    ref_J_r[17] << -5.711426, 4.983738, 0.063848, 0.510382, 0.663497, -6.134650;
    ref_J_r[18] << -0.002769, 0.009762, -0.000409, 0.004978, 0.001061,
            -0.008368;
    ref_J_r[19] << -0.407277, 1.113711, 0.097469, 0.116251, 0.151126, -1.241065;

    float ref_r_raw[] = {
            0.075062,  0.829537, -0.064539, 0.949145,  0.049106,
            0.999303,  0.101018, 0.601897,  0.149422,  0.922137,
            -0.063136, 0.231499, -0.097510, 1.207652,  -0.064539,
            0.949145,  0.021747, 1.408284,  -0.016836, 0.470714,
    };
    thrust::host_vector<float> ref_r;
    for (int i = 0; i < 20; ++i) ref_r.push_back(ref_r_raw[i]);

    int width = 10;
    int height = 10;
    // int num_of_channels = 1;
    // int bytes_per_channel = 4;

    auto srcColor = GenerateImage(width, height, 1, 4, 0.0f, 1.0f, 1);
    auto srcDepth = GenerateImage(width, height, 1, 4, 0.0f, 1.0f, 0);

    auto tgtColor = GenerateImage(width, height, 1, 4, 0.0f, 1.0f, 1);
    auto tgtDepth = GenerateImage(width, height, 1, 4, 1.0f, 2.0f, 0);

    auto dxColor = GenerateImage(width, height, 1, 4, 0.0f, 1.0f, 1);
    auto dyColor = GenerateImage(width, height, 1, 4, 0.0f, 1.0f, 1);

    ShiftLeft(tgtColor, 10);
    ShiftUp(tgtColor, 5);

    ShiftLeft(dxColor, 10);
    ShiftUp(dyColor, 5);

    geometry::RGBDImage source(*srcColor, *srcDepth);
    geometry::RGBDImage target(*tgtColor, *tgtDepth);
    auto source_xyz = GenerateImage(width, height, 3, 4, 0.0f, 1.0f, 0);
    geometry::RGBDImage target_dx(*dxColor, *tgtDepth);
    geometry::RGBDImage target_dy(*dyColor, *tgtDepth);

    Matrix3f intrinsic = Matrix3f::Zero();
    intrinsic(0, 0) = 0.5;
    intrinsic(1, 1) = 0.65;
    intrinsic(0, 2) = 0.75;
    intrinsic(1, 2) = 0.35;

    Matrix4f extrinsic = Matrix4f::Zero();
    extrinsic(0, 0) = 1.0;
    extrinsic(1, 1) = 1.0;
    extrinsic(2, 2) = 1.0;

    int rows = height;
    thrust::host_vector<Vector4i> corresps(rows);
    Rand(corresps, 0, 3, 0);

    odometry::RGBDOdometryJacobianFromHybridTerm jacobian_method;

    for (int row = 0; row < rows; row++) {
        Vector6f J_r[2];
        float r[2];

        jacobian_method.ComputeJacobianAndResidual(
                row, J_r, r,
                thrust::raw_pointer_cast(source.color_.GetData().data()),
                thrust::raw_pointer_cast(source.depth_.GetData().data()),
                thrust::raw_pointer_cast(target.color_.GetData().data()),
                thrust::raw_pointer_cast(target.depth_.GetData().data()),
                thrust::raw_pointer_cast(source_xyz->GetData().data()),
                thrust::raw_pointer_cast(target_dx.color_.GetData().data()),
                thrust::raw_pointer_cast(target_dx.depth_.GetData().data()),
                thrust::raw_pointer_cast(target_dy.color_.GetData().data()),
                thrust::raw_pointer_cast(target_dy.depth_.GetData().data()),
                width, intrinsic, extrinsic,
                thrust::raw_pointer_cast(corresps.data()));

        EXPECT_NEAR(ref_r[2 * row + 0], r[0], THRESHOLD_1E_4);
        EXPECT_NEAR(ref_r[2 * row + 1], r[1], THRESHOLD_1E_4);

        ExpectEQ(ref_J_r[2 * row + 0], J_r[0]);
        ExpectEQ(ref_J_r[2 * row + 1], J_r[1]);
    }
}
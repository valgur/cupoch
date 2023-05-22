/**
 * Copyright (c) 2020 Neka-Nat
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
**/
#include "cupoch/geometry/pointcloud.h"
#include "cupoch/io/class_io/pointcloud_io.h"
#include "cupoch/registration/registration.h"
#include "cupoch/utility/console.h"
#include "cupoch/utility/helper.h"
#include "cupoch/visualization/utility/draw_geometry.h"

int main(int argc, char *argv[]) {
    using namespace cupoch;
    utility::InitializeAllocator();

    utility::SetVerbosityLevel(utility::VerbosityLevel::Debug);
    if (argc < 3) {utility::LogInfo("Need two arguments of point cloud file name."); return 0;}

    auto source = std::make_shared<geometry::PointCloud>();
    auto target = std::make_shared<geometry::PointCloud>();
    auto result = std::make_shared<geometry::PointCloud>();
    if (io::ReadPointCloud(argv[1], *source)) {
        utility::LogInfo("Successfully read {}", argv[1]);
    } else {
        utility::LogWarning("Failed to read {}", argv[1]);
    }
    if (io::ReadPointCloud(argv[2], *target)) {
        utility::LogInfo("Successfully read {}", argv[2]);
    } else {
        utility::LogWarning("Failed to read {}", argv[2]);
    }
    Eigen::Matrix4f init = (Eigen::Matrix4f() << 0.862, 0.011, -0.507, 0.5,
                                -0.139, 0.967, -0.215, 0.7,
                                0.487, 0.255, 0.835, -1.4,
                                0.0, 0.0, 0.0, 1.0).finished();
    auto res = registration::RegistrationICP(*source, *target, 0.02, init);
    std::cout << res.transformation_ << std::endl;
    *result = *source;
    result->Transform(res.transformation_);
    visualization::DrawGeometries({source, target, result});
    return 0;
}
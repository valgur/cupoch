#include <cupoch/geometry/pointcloud.h>
#include <cupoch/knn/kdtree_search_param.h>
#include <cupoch/registration/registration.h>

#include <Eigen/Core>
#include <Eigen/Geometry>
#include <iostream>

int main() {
    using namespace cupoch::registration;
    ICPConvergenceCriteria icp_criteria;
    TransformationEstimationPointToPoint point_to_point;
    TransformationEstimationPointToPlane point_to_plane;
    std::vector<Eigen::Vector3f> points = {{0, 0, 0}, {1, 1, 1}, {2, 2, 2}};
    cupoch::geometry::PointCloud target{points};
    cupoch::geometry::PointCloud source{points};
    std::cout << "cupoch ICP setup ran successfully\n";
    RegistrationResult icp_result = cupoch::registration::RegistrationICP(
            source, target, 1, Eigen::Isometry3f::Identity().matrix(),
            point_to_point, icp_criteria);
    std::cout << "cupoch::registration::RegistrationICP() ran successfully\n";
}

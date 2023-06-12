#include <cupoch/kinematics/kinematic_chain.h>

using namespace cupoch;

void testKinematics() {
    auto kin = kinematics::KinematicChain();
    auto poses = kin.ForwardKinematics();
    auto meshes = kin.GetTransformedVisualGeometryMap(poses);
    std::vector<std::shared_ptr<const geometry::Geometry>> geoms;
    for (const auto& m : meshes) {
        geoms.push_back(m.second);
    }
}

int main() {
    // Only testing that the code compiles and links.
    return 0;
}

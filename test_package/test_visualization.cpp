#include <cupoch/geometry/pointcloud.h>
#include <cupoch/io/class_io/pointcloud_io.h>
#include <cupoch/visualization/utility/draw_geometry.h>

using namespace cupoch;

void displayPointCloud() {
    auto pcd = io::CreatePointCloudFromFile("test.ply");
    pcd->EstimateNormals();
    visualization::DrawGeometries({pcd});
}

int main() {
    // Only testing that the code compiles and links.
    return 0;
}

# build
file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")

# create object library
add_library(cupoch_odometry ${ALL_CUDA_SOURCE_FILES})
target_link_libraries(cupoch_odometry
    PUBLIC
        cupoch_camera
        cupoch_utility
    PRIVATE
        cupoch_geometry
        Eigen3::Eigen
)

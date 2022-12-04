# build
file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")

# create object library
add_library(cupoch_knn ${ALL_CUDA_SOURCE_FILES})
target_link_libraries(cupoch_knn
    PUBLIC
        cupoch_utility
        Eigen3::Eigen
        lbvh::lbvh_index
    PRIVATE
        cupoch_flags
        flann::flann_cuda_s
)
file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")
add_library(cupoch_registration ${ALL_CUDA_SOURCE_FILES})
target_link_libraries(cupoch_registration
    PUBLIC
        cupoch_knn
        cupoch_utility
        stdgpu
    PRIVATE
        cupoch_flags
        cupoch_geometry
        Eigen3::Eigen
)

# build
file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")

# create object library
add_library(cupoch_integration ${ALL_CUDA_SOURCE_FILES})
target_link_libraries(cupoch_integration
    PUBLIC
        cupoch_camera
        cupoch_geometry
    PRIVATE
        cupoch_flags
        cupoch_utility
        stdgpu
)

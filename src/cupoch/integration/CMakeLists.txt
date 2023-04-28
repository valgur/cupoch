option(BUILD_cupoch_integration "Include cupoch_integration module in the build" TRUE)
if(NOT BUILD_cupoch_integration)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_integration PARENT_SCOPE)

find_package(stdgpu REQUIRED CONFIG)

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
        stdgpu::stdgpu
)

if(NOT BUILD_cupoch_registration)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_registration PARENT_SCOPE)

find_package(stdgpu REQUIRED CONFIG)

file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")
add_library(cupoch_registration ${ALL_CUDA_SOURCE_FILES})
add_library(cupoch::registration ALIAS cupoch_registration)
target_link_libraries(cupoch_registration
    PUBLIC
        cupoch::knn
        cupoch::utility
        stdgpu::stdgpu
        cupoch::flags
        cupoch::geometry
        Eigen3::Eigen
)

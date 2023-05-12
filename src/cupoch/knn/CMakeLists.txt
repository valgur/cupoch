if(NOT BUILD_cupoch_knn)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_knn PARENT_SCOPE)

find_package(flann_cuda REQUIRED CONFIG)
find_package(lbvh REQUIRED CONFIG)

# build
file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")

# create object library
add_library(cupoch_knn ${ALL_CUDA_SOURCE_FILES})
target_link_libraries(cupoch_knn
    PUBLIC
        cupoch_utility
        Eigen3::Eigen
        lbvh::lbvh_index
        flann::flann_cuda_s
    PRIVATE
        cupoch_flags
)
if(NOT BUILD_cupoch_odometry)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_odometry PARENT_SCOPE)

find_package(Eigen3 REQUIRED CONFIG)

# build
file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")

# create object library
add_library(cupoch_odometry ${ALL_CUDA_SOURCE_FILES})
add_library(cupoch::odometry ALIAS cupoch_odometry)
target_compile_definitions(cupoch_odometry PUBLIC CUPOCH_ODOMETRY_ENABLED)
target_link_libraries(cupoch_odometry
    PUBLIC
        cupoch::camera
        cupoch::geometry
        cupoch::utility
    PRIVATE
        Eigen3::Eigen
)

option(BUILD_cupoch_geometry "Include cupoch_geometry module in the build" TRUE)
if(NOT BUILD_cupoch_geometry)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_geometry PARENT_SCOPE)

find_package(stdgpu REQUIRED CONFIG)
find_package(tritriintersect REQUIRED CONFIG)

file(GLOB_RECURSE GEOMETRY_SOURCE_FILES "*.cu")
add_library(cupoch_geometry ${GEOMETRY_SOURCE_FILES})
target_link_libraries(cupoch_geometry
    PUBLIC
        cupoch_utility
        cupoch_camera
        cupoch_knn
        Eigen3::Eigen
        tritriintersect::tritriintersect
    PRIVATE
        cupoch_flags
        stdgpu::stdgpu
)

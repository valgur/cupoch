if(NOT BUILD_cupoch_collision)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_collision PARENT_SCOPE)

find_package(lbvh REQUIRED CONFIG)
find_package(stdgpu REQUIRED CONFIG)
find_package(tritriintersect REQUIRED CONFIG)

file(GLOB_RECURSE COLLISION_SOURCE_FILES "*.cu")
add_library(cupoch_collision ${COLLISION_SOURCE_FILES})
target_link_libraries(cupoch_collision
    PUBLIC
        cupoch_geometry
        Eigen3::Eigen
    PRIVATE
        cupoch_flags
        cupoch_utility
        lbvh::lbvh
        lbvh::lbvh_index
        stdgpu::stdgpu
        tritriintersect::tritriintersect
)

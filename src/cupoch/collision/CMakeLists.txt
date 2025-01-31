if(NOT BUILD_cupoch_collision)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_collision PARENT_SCOPE)

find_package(Eigen3 REQUIRED CONFIG)
find_package(lbvh REQUIRED CONFIG)
find_package(stdgpu REQUIRED CONFIG)
find_package(tritriintersect REQUIRED CONFIG)

file(GLOB_RECURSE COLLISION_SOURCE_FILES "*.cu")
add_library(cupoch_collision ${COLLISION_SOURCE_FILES})
add_library(cupoch::collision ALIAS cupoch_collision)
target_compile_definitions(cupoch_collision PUBLIC CUPOCH_COLLISION_ENABLED)
target_link_libraries(cupoch_collision
    PUBLIC
        cupoch::geometry
        Eigen3::Eigen
    PRIVATE
        cupoch::flags
        lbvh::lbvh
        lbvh::lbvh_index
        stdgpu::stdgpu
        tritriintersect::tritriintersect
)

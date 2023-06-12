if(NOT BUILD_cupoch_geometry)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_geometry PARENT_SCOPE)

find_package(Eigen3 REQUIRED CONFIG)
find_package(stdgpu REQUIRED CONFIG)
find_package(tritriintersect REQUIRED CONFIG)

file(GLOB_RECURSE GEOMETRY_SOURCE_FILES "*.cu")
add_library(cupoch_geometry ${GEOMETRY_SOURCE_FILES})
add_library(cupoch::geometry ALIAS cupoch_geometry)
target_compile_definitions(cupoch_geometry PUBLIC CUPOCH_GEOMETRY_ENABLED)
target_link_libraries(cupoch_geometry
    PUBLIC
        cupoch::utility
        cupoch::camera
        cupoch::knn
        Eigen3::Eigen
        tritriintersect::tritriintersect
    PRIVATE
        cupoch::flags
        stdgpu::stdgpu
)

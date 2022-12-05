file(GLOB_RECURSE GEOMETRY_SOURCE_FILES "*.cu")
add_library(cupoch_geometry ${GEOMETRY_SOURCE_FILES})
target_link_libraries(cupoch_geometry
    PUBLIC
        cupoch_utility
        cupoch_camera
        cupoch_knn
        Eigen3::Eigen
        tomasakeninemoeller::tritriintersect
    PRIVATE
        cupoch_flags
        stdgpu
)

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
        stdgpu
        tomasakeninemoeller::tritriintersect
)

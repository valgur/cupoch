file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")
add_library(cupoch_planning ${ALL_CUDA_SOURCE_FILES})
target_link_libraries(cupoch_planning
    PUBLIC
        cupoch_geometry
    PRIVATE
        cupoch_collision
        cupoch_utility
)

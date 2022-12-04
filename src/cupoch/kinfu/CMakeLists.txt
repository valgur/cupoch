file(GLOB_RECURSE KINFU_SOURCE_FILES "*.cpp")

# Create object library
add_library(cupoch_kinfu ${KINFU_SOURCE_FILES})
target_link_libraries(cupoch_kinfu
    PUBLIC
        cupoch_camera
        cupoch_geometry
        cupoch_integration
        cupoch_registration
)

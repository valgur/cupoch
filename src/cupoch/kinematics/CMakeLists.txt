file(GLOB_RECURSE KINEMATICS_SOURCE_FILES "*.cpp")

# Create object library
add_library(cupoch_kinematics ${KINEMATICS_SOURCE_FILES})
target_link_libraries(cupoch_kinematics
    PUBLIC
        cupoch_collision
        cupoch_io
        cupoch_utility
        urdfdom::urdfdom
    PRIVATE
        cupoch_utility
)

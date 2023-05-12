if(NOT BUILD_cupoch_kinematics)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_kinematics PARENT_SCOPE)

find_package(urdfdom REQUIRED CONFIG)

file(GLOB_RECURSE KINEMATICS_SOURCE_FILES "*.cpp")

# Create object library
add_library(cupoch_kinematics ${KINEMATICS_SOURCE_FILES})
add_library(cupoch::kinematics ALIAS cupoch_kinematics)
target_link_libraries(cupoch_kinematics
    PUBLIC
        cupoch::collision
        cupoch::io
        cupoch::utility
        urdfdom::urdfdom
)

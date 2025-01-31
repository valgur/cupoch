if(NOT BUILD_cupoch_kinematics)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_kinematics PARENT_SCOPE)

find_package(urdfdom REQUIRED CONFIG)

file(GLOB_RECURSE KINEMATICS_SOURCE_FILES "*.cpp")
set_source_files_properties(${KINEMATICS_SOURCE_FILES} PROPERTIES LANGUAGE CUDA)

# Create object library
add_library(cupoch_kinematics ${KINEMATICS_SOURCE_FILES})
add_library(cupoch::kinematics ALIAS cupoch_kinematics)
target_compile_definitions(cupoch_kinematics PUBLIC CUPOCH_KINEMATICS_ENABLED)
target_link_libraries(cupoch_kinematics
    PUBLIC
        cupoch::collision
        cupoch::flags
        urdfdom::urdfdom
    PRIVATE
        cupoch::geometry
        cupoch::io
        cupoch::utility
)

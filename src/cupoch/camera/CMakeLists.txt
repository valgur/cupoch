if(NOT BUILD_cupoch_camera)
    return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_camera PARENT_SCOPE)

file(GLOB_RECURSE CAMERA_SOURCE_FILES "*.cpp")
add_library(cupoch_camera ${CAMERA_SOURCE_FILES})
target_link_libraries(cupoch_camera
    PUBLIC
        cupoch_utility
        Eigen3::Eigen
    PRIVATE
        cupoch_flags
)

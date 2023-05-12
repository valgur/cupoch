if(NOT BUILD_cupoch_kinfu)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_kinfu PARENT_SCOPE)

file(GLOB_RECURSE KINFU_SOURCE_FILES "*.cpp")

# Create object library
add_library(cupoch_kinfu ${KINFU_SOURCE_FILES})
add_library(cupoch::kinfu ALIAS cupoch_kinfu)
target_compile_definitions(cupoch_kinfu PUBLIC CUPOCH_KINFU_ENABLED)
target_link_libraries(cupoch_kinfu
    PUBLIC
        cupoch::camera
        cupoch::geometry
        cupoch::integration
        cupoch::registration
)

if(NOT BUILD_cupoch_imageproc)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_imageproc PARENT_SCOPE)

find_package(sgm REQUIRED CONFIG)

file(GLOB_RECURSE IMAGEPROC_SOURCE_FILES "*.cpp")
add_library(cupoch_imageproc ${IMAGEPROC_SOURCE_FILES})
target_link_libraries(cupoch_imageproc
    PUBLIC
        cupoch_geometry
        sgm::sgm
    PRIVATE
        cupoch_utility
)

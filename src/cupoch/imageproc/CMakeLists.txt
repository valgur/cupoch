if(NOT BUILD_cupoch_imageproc)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_imageproc PARENT_SCOPE)

find_package(LibSGM REQUIRED CONFIG)

file(GLOB_RECURSE IMAGEPROC_SOURCE_FILES "*.cpp")
add_library(cupoch_imageproc ${IMAGEPROC_SOURCE_FILES})
add_library(cupoch::imageproc ALIAS cupoch_imageproc)
target_compile_definitions(cupoch_imageproc PUBLIC CUPOCH_IMAGEPROC_ENABLED)
target_link_libraries(cupoch_imageproc
    PUBLIC
        cupoch::geometry
        LibSGM::sgm
    PRIVATE
        cupoch::utility
)

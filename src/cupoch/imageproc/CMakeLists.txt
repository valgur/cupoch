if(NOT BUILD_cupoch_imageproc)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_imageproc PARENT_SCOPE)

find_package(LibSGM REQUIRED CONFIG)

if(NOT TARGET LibSGM::sgm)
  add_library(LibSGM::sgm INTERFACE IMPORTED)
  set_target_properties(LibSGM::sgm PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${LIBSGM_INCLUDE_DIRS}"
    INTERFACE_LINK_LIBRARIES "${LIBSGM_LIBRARIES}"
  )
endif()

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

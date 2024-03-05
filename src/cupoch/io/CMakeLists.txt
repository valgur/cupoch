if(NOT BUILD_cupoch_io)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_io PARENT_SCOPE)

find_package(JPEG REQUIRED)
find_package(liblzf REQUIRED CONFIG)
find_package(PNG REQUIRED)
find_package(rply REQUIRED CONFIG)
find_package(tinyobjloader REQUIRED CONFIG)

file(GLOB_RECURSE IO_CPP_SOURCE_FILES "*.cpp")
file(GLOB_RECURSE IO_CUDA_SOURCE_FILES "*.cu")
set(IO_ALL_SOURCE_FILES ${IO_CPP_SOURCE_FILES} ${IO_CUDA_SOURCE_FILES})

# Create object library
add_library(cupoch_io ${IO_ALL_SOURCE_FILES})
add_library(cupoch::io ALIAS cupoch_io)
target_compile_definitions(cupoch_io PUBLIC CUPOCH_IO_ENABLED)
target_link_libraries(cupoch_io
    PUBLIC
        cupoch::geometry
        cupoch::utility
    PRIVATE
        cupoch::flags
        liblzf::liblzf
        PNG::PNG
        rply::rply
        tinyobjloader::tinyobjloader
        JPEG::JPEG
)

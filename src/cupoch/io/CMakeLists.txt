if(NOT BUILD_cupoch_io)
  return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_io PARENT_SCOPE)

find_package(libjpeg-turbo REQUIRED CONFIG)
find_package(liblzf REQUIRED CONFIG)
find_package(PNG REQUIRED CONFIG)
find_package(rply REQUIRED CONFIG)
find_package(tinyobjloader REQUIRED CONFIG)

file(GLOB_RECURSE IO_CPP_SOURCE_FILES "*.cpp")
file(GLOB_RECURSE IO_CUDA_SOURCE_FILES "*.cu")
set(IO_ALL_SOURCE_FILES ${IO_CPP_SOURCE_FILES} ${IO_CUDA_SOURCE_FILES})

# Create object library
add_library(cupoch_io ${IO_ALL_SOURCE_FILES})
target_link_libraries(cupoch_io
    PUBLIC
        cupoch_geometry
        cupoch_utility
        Eigen3::Eigen
    PRIVATE
        cupoch_flags
        liblzf::liblzf
        PNG::PNG
        rply::rply
        tinyobjloader::tinyobjloader
        libjpeg-turbo::libjpeg-turbo
)

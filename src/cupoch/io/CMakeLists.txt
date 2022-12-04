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
        JsonCpp::JsonCpp
        liblzf::liblzf
        PNG::PNG
        rply::rply
        tinyobjloader::tinyobjloader
        libjpeg-turbo::libjpeg-turbo
)

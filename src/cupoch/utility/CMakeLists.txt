find_package(dlpack REQUIRED CONFIG)
find_package(jsoncpp REQUIRED CONFIG)
find_package(OpenGL REQUIRED)
find_package(spdlog REQUIRED CONFIG)

file(GLOB_RECURSE ALL_CPP_SOURCE_FILES "*.cpp")
file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")
add_library(cupoch_utility ${ALL_CUDA_SOURCE_FILES} ${ALL_CPP_SOURCE_FILES})
target_link_libraries(cupoch_utility
    PUBLIC
        cupoch_flags
        dlpack::dlpack
        Eigen3::Eigen
        JsonCpp::JsonCpp
        rmm::rmm
        stdgpu
    PRIVATE
        OpenGL::GL
        spdlog::spdlog
)

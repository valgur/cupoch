set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_utility PARENT_SCOPE)

find_package(dlpack REQUIRED CONFIG)
find_package(jsoncpp REQUIRED CONFIG)
find_package(OpenGL REQUIRED)
find_package(stdgpu REQUIRED CONFIG)

file(GLOB_RECURSE ALL_CPP_SOURCE_FILES "*.cpp")
file(GLOB_RECURSE ALL_CUDA_SOURCE_FILES "*.cu")
add_library(cupoch_utility ${ALL_CUDA_SOURCE_FILES} ${ALL_CPP_SOURCE_FILES})
add_library(cupoch::utility ALIAS cupoch_utility)
target_compile_definitions(cupoch_utility PUBLIC CUPOCH_UTILITY_ENABLED)
target_link_libraries(cupoch_utility
    PUBLIC
        cupoch::flags
        dlpack::dlpack
        Eigen3::Eigen
        JsonCpp::JsonCpp
        spdlog::spdlog
        stdgpu::stdgpu
    PRIVATE
        OpenGL::GL
)

if(USE_RMM)
    find_package(rmm REQUIRED CONFIG)
    target_link_libraries(cupoch_utility PUBLIC rmm::rmm)
endif()

file(GLOB_RECURSE CAMERA_SOURCE_FILES "*.cpp")
cuda_add_library(cupoch_camera ${CAMERA_SOURCE_FILES})
target_link_libraries(cupoch_camera
    Eigen3::Eigen
    spdlog::spdlog
    JsonCpp::JsonCpp
)
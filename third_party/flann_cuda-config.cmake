if(TARGET flann_cuda_s)
  return()
endif()

set(flann_cuda_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/flann)

file(GLOB_RECURSE CU_SOURCES ${flann_cuda_SOURCE_DIR}/*.cu)
add_library(flann_cuda_s STATIC ${CU_SOURCES})
add_library(flann::flann_cuda_s ALIAS flann_cuda_s)
target_include_directories(flann_cuda_s PUBLIC $<BUILD_INTERFACE:${flann_cuda_SOURCE_DIR}>)
target_compile_definitions(flann_cuda_s PUBLIC FLANN_USE_CUDA)
target_link_libraries(flann_cuda_s PRIVATE cupoch::flags CUDA::cudart spdlog::spdlog)
if(USE_RMM)
  find_package(rmm REQUIRED CONFIG)
  target_link_libraries(flann_cuda_s PRIVATE rmm::rmm)
endif()
install(TARGETS flann_cuda_s)
install(DIRECTORY ${flann_cuda_SOURCE_DIR}/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")

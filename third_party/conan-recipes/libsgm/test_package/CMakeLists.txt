cmake_minimum_required(VERSION 3.18)
project(test_package CXX CUDA)

find_package(LibSGM CONFIG REQUIRED)
find_package(CUDAToolkit REQUIRED)

add_executable(${PROJECT_NAME} test_package.cpp)
# Linking with cudart fails if the source file is not marked as CUDA for some reason
set_source_files_properties(test_package.cpp PROPERTIES LANGUAGE CUDA)
target_link_libraries(${PROJECT_NAME} LibSGM::sgm CUDA::cudart)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)
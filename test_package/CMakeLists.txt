cmake_minimum_required(VERSION 3.15)
project(PackageTest LANGUAGES CXX CUDA)

find_package(cupoch REQUIRED)
find_package(CUDAToolkit REQUIRED)

add_executable(example example.cpp)
target_link_libraries(example PRIVATE cupoch::cupoch CUDA::cudart)
target_compile_features(example PRIVATE cxx_std_17)

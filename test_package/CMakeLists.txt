cmake_minimum_required(VERSION 3.15)
project(PackageTest LANGUAGES CXX CUDA)

find_package(cupoch REQUIRED)
find_package(CUDAToolkit REQUIRED)

add_executable(test_registration test_registration.cpp)
target_link_libraries(test_registration PRIVATE cupoch::cupoch CUDA::cudart)
target_compile_features(test_registration PRIVATE cxx_std_17)

cmake_minimum_required(VERSION 3.18)
project(PackageTest LANGUAGES CXX CUDA)

find_package(cupoch REQUIRED)

add_executable(test_registration test_registration.cpp)
target_link_libraries(test_registration PRIVATE cupoch::cupoch)

cmake_minimum_required(VERSION 3.18)
project(PackageTest LANGUAGES CXX CUDA)

find_package(cupoch REQUIRED)

# Build a separate test executable for each module with external dependencies
# to ensure that everything compiles and links correctly.

# Using cupoch::cupoch as the link_libraries would also work.

if (TARGET cupoch::imageproc)
    add_executable(test_imageproc test_imageproc.cpp)
    target_link_libraries(test_imageproc PRIVATE cupoch::imageproc cupoch::io)
endif()

if (TARGET cupoch::io)
    add_executable(test_io test_io.cpp)
    target_link_libraries(test_io PRIVATE cupoch::io)
endif()

if (TARGET cupoch::kinematics)
    add_executable(test_kinematics test_kinematics.cpp)
    target_link_libraries(test_kinematics PRIVATE cupoch::kinematics)
endif()

if (TARGET cupoch::registration)
    add_executable(test_registration test_registration.cpp)
    target_link_libraries(test_registration PRIVATE cupoch::registration)
endif()

if (TARGET cupoch::visualization)
    add_executable(test_visualization test_visualization.cpp)
    target_link_libraries(test_visualization PRIVATE cupoch::visualization)
endif()

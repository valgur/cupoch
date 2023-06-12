cmake_minimum_required(VERSION 3.18)
project(PackageTest LANGUAGES CXX CUDA)

find_package(cupoch REQUIRED)

if (TARGET cupoch::registration)
    add_executable(test_registration test_registration.cpp)
    target_link_libraries(test_registration PRIVATE cupoch::registration)
endif()

if (TARGET cupoch::kinematics)
    add_executable(test_kinematics test_kinematics.cpp)
    target_link_libraries(test_kinematics PRIVATE cupoch::kinematics)
endif()

if (TARGET cupoch::io)
    add_executable(test_io test_io.cpp)
    target_link_libraries(test_io PRIVATE cupoch::io)
endif()

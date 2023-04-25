cmake_minimum_required(VERSION 3.18)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(set_cupoch_version)
project(cupoch VERSION ${CUPOCH_VERSION} LANGUAGES CXX CUDA)

# PyPI package name controls specifies the repository name on PyPI. The default
# name is "cupoch". 
if(NOT DEFINED PYPI_PACKAGE_NAME)
    set(PYPI_PACKAGE_NAME "cupoch")
endif()

# set additional info
set(PROJECT_EMAIL   "nekanat.stock@gmail.com")
set(PROJECT_HOME    "https://github.com/neka-nat/cupoch")
set(PROJECT_DOCS    "https://github.com/neka-nat/cupoch")
set(PROJECT_CODE    "https://github.com/neka-nat/cupoch")
set(PROJECT_ISSUES  "https://github.com/neka-nat/cupoch/issues")


if(WIN32 AND NOT CYGWIN)
    set(DEF_INSTALL_CMAKE_DIR CMake)
else()
    set(DEF_INSTALL_CMAKE_DIR lib/cmake/cupoch)
endif()
set(INSTALL_CMAKE_DIR ${DEF_INSTALL_CMAKE_DIR} CACHE PATH
    "Installation directory for CMake files")

option(BUILD_UNIT_TESTS          "Build the Cupoch unit tests"              ON)
option(BUILD_EXAMPLES            "Build the Cupoch examples"                ON)
option(BUILD_PYTHON_MODULE       "Build the python module"                  ON)
option(USE_RMM                   "Use rmm library(fast memory allocator)"   ON)
option(STATIC_WINDOWS_RUNTIME    "Use static (MT/MTd) Windows runtime"      OFF)
option(CMAKE_USE_RELATIVE_PATHS  "If true, cmake will use relative paths"   ON)

include(GNUInstallDirs)
if(UNIX)
    set(CUPOCH_INSTALL_CMAKE_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
else()
    set(CUPOCH_INSTALL_CMAKE_DIR CMake)
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

if (WIN32)
    # can't hide the unit testing option on Windows only
    # as a precaution: disable unit testing on Windows regardless of user input
    message(STATUS "Disable unit tests since this feature is not fully supported on Windows.")
    set(BUILD_UNIT_TESTS OFF)
    set(USE_RMM OFF)
    add_definitions(-DWINDOWS)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS)		# suppress C4996 warning
    add_definitions(-DGLEW_STATIC)		# enable GLEW for windows
    add_definitions(-DTHRUST_CPP11_REQUIRED_NO_ERROR)
    SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    message(STATUS "Compiling on Windows")
    if (MSVC)
        message(STATUS "Compiling with MSVC")
        add_definitions(-DNOMINMAX)
        add_definitions(-D_USE_MATH_DEFINES)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc /Zc:__cplusplus /bigobj /std:c++17")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D _ENABLE_EXTENDED_ALIGNED_STORAGE")
        set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MP")
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MP")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MP")
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MP")
        set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} --no-host-device-move-forward)
        set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} -DTHRUST_DEVICE_SYSTEM=THRUST_DEVICE_SYSTEM_CUDA)
    endif (MSVC)

    if (STATIC_WINDOWS_RUNTIME)
        # by default, "/MD" and "/MDd" is set by CMake automatically
        string(REPLACE "/MD" "/MT" CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})
        string(REPLACE "/MDd" "/MTd" CMAKE_C_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})
        string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
        string(REPLACE "/MDd" "/MTd" CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
    else ()
        # handles the case when re-running cmake with STATIC_WINDOWS_RUNTIME=OFF
        string(REPLACE "/MT" "/MD" CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})
        string(REPLACE "/MTd" "/MDd" CMAKE_C_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})
        string(REPLACE "/MT" "/MD" CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
        string(REPLACE "/MTd" "/MDd" CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG})
    endif ()
    message(STATUS "CMAKE_C_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE}")
    message(STATUS "CMAKE_C_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG}")
    message(STATUS "CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE}")
    message(STATUS "CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG}")
elseif (CYGWIN)
    SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    message(STATUS "Compiling on Cygwin")
    # enable c++17
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
    add_definitions(-DCYGWIN)
elseif (APPLE)
    add_definitions(-DUNIX)
    # enable c++17
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
    add_compile_options(-Wno-deprecated-declarations)
    if (NOT BUILD_SHARED_LIBS)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")
    endif (NOT BUILD_SHARED_LIBS)
    # In Release build -O3 will be added automatically by CMake
    # We still enable -O3 at Debug build to optimize performance
    string(TOUPPER "${CMAKE_BUILD_TYPE}" uppercase_CMAKE_BUILD_TYPE)
    if (uppercase_CMAKE_BUILD_TYPE STREQUAL "DEBUG")
        add_compile_options(-O3)
    endif()
elseif (UNIX)
    add_definitions(-DUNIX)
    # TODO: replace these with CMake properties:
    # - POSITION_INDEPENDENT_CODE
    # - CXX_STANDARD
    # - CMAKE_CXX_VISIBILITY_PRESET
    # enable c++17
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fPIC")
    if (NOT BUILD_SHARED_LIBS)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden -fvisibility-inlines-hidden")
    endif (NOT BUILD_SHARED_LIBS)
    add_compile_options(-Wno-deprecated-declarations)
    # In Release build -O3 will be added automatically by CMake
    # We still enable -O3 at debug build to optimize performance
    string(TOUPPER "${CMAKE_BUILD_TYPE}" uppercase_CMAKE_BUILD_TYPE)
    if (uppercase_CMAKE_BUILD_TYPE STREQUAL "DEBUG")
        add_compile_options(-O3)
    endif()
    # disable BUILD_LIBREALSENSE since it is not fully supported on Linux
    message(STATUS "Compiling on Unix")
endif ()

find_package(CUDAToolkit REQUIRED)
add_library(cupoch_flags INTERFACE)
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    # Generate for 10xx+ series GPUs by default.
    # Newer but not listed GPUs will JIT compile on launch.
    set(CMAKE_CUDA_ARCHITECTURES 61)
endif()
target_compile_features(cupoch_flags INTERFACE cxx_std_17 $<BUILD_INTERFACE:cuda_std_17>)
target_compile_options(cupoch_flags INTERFACE
    "$<$<COMPILE_LANGUAGE:CUDA>:--expt-relaxed-constexpr>"
    "$<$<COMPILE_LANGUAGE:CUDA>:--expt-extended-lambda>"
    "$<$<COMPILE_LANGUAGE:CUDA>:--default-stream=per-thread>"
    "$<$<COMPILE_LANGUAGE:CUDA>:--use_fast_math>"
    "$<$<BOOL:UNIX>:$<$<COMPILE_LANGUAGE:CUDA>:--compiler-options=-fPIC>>"
    "$<$<COMPILE_LANGUAGE:CUDA>:-Xcudafe=--diag_suppress=integer_sign_change>"
    "$<$<COMPILE_LANGUAGE:CUDA>:-Xcudafe=--diag_suppress=partial_override>"
    "$<$<COMPILE_LANGUAGE:CUDA>:-Xcudafe=--diag_suppress=virtual_function_decl_hidden>"
)
target_link_libraries(cupoch_flags INTERFACE CUDA::cudart)
if (USE_RMM)
    target_compile_definitions(cupoch_flags INTERFACE USE_RMM)
endif ()

# 3rd-party projects that are added with external_project_add will be installed
# with this prefix. E.g.
# - 3RDPARTY_INSTALL_PREFIX: cupoch/build/3rdparty_install
# - Headers: cupoch/build/3rdparty_install/include/extern_lib.h
# - Libraries: cupoch/build/3rdparty_install/lib/extern_lib.a
set(3RDPARTY_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/3rdparty_install")

## conan libraries ##
if(NOT DEFINED CONAN_CXX_FLAGS)
    include(conan_dependencies)
    conan_dependencies_file(${CMAKE_SOURCE_DIR}/conanfile.py)
endif()

find_package(dlpack REQUIRED CONFIG)
find_package(Eigen3 REQUIRED CONFIG)
find_package(GLEW REQUIRED CONFIG)
find_package(glfw3 REQUIRED CONFIG)
find_package(GTest REQUIRED CONFIG)
find_package(imgui REQUIRED CONFIG)
find_package(jsoncpp REQUIRED CONFIG)
find_package(libjpeg-turbo REQUIRED CONFIG)
find_package(OpenGL REQUIRED)
find_package(PNG REQUIRED CONFIG)
find_package(pybind11 REQUIRED CONFIG)
find_package(rply REQUIRED CONFIG)
find_package(spdlog REQUIRED CONFIG)
find_package(tinyobjloader REQUIRED CONFIG)

add_subdirectory(third_party)

include_directories(src)
add_subdirectory(src)
if (BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()
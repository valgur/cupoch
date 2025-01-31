list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(set_cupoch_version)

cmake_minimum_required(VERSION 3.18 FATAL_ERROR)
project(cupoch VERSION ${CUPOCH_VERSION})

# Must be handled before enable_language(CUDA)
if (NOT CMAKE_CUDA_ARCHITECTURES AND NOT DEFINED INIT_ARCHITECTURES)
    set(INIT_ARCHITECTURES TRUE)
endif()

enable_language(CXX)
enable_language(CUDA)

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

option(BUILD_cupoch_camera        "Include cupoch_camera module in the build"        ON)
option(BUILD_cupoch_collision     "Include cupoch_collision module in the build"     ON)
option(BUILD_cupoch_geometry      "Include cupoch_geometry module in the build"      ON)
option(BUILD_cupoch_imageproc     "Include cupoch_imageproc module in the build"     ON)
option(BUILD_cupoch_integration   "Include cupoch_integration module in the build"   ON)
option(BUILD_cupoch_io            "Include cupoch_io module in the build"            ON)
option(BUILD_cupoch_kinematics    "Include cupoch_kinematics module in the build"    ON)
option(BUILD_cupoch_kinfu         "Include cupoch_kinfu module in the build"         ON)
option(BUILD_cupoch_knn           "Include cupoch_knn module in the build"           ON)
option(BUILD_cupoch_odometry      "Include cupoch_odometry module in the build"      ON)
option(BUILD_cupoch_planning      "Include cupoch_planning module in the build"      ON)
option(BUILD_cupoch_registration  "Include cupoch_registration module in the build"  ON)
option(BUILD_cupoch_visualization "Include cupoch_visualization module in the build" ON)

## conan libraries ##
include(conan_dependencies)
set(CMAKE_CXX_STANDARD 17) # for the autodetected Conan profile
if(NOT BUILD_TRIGGERED_BY_CONAN)
    conan_dependencies_file(${CMAKE_SOURCE_DIR}/conanfile.py)
    if(BUILD_PYTHON_MODULE)
        conan_dependencies(pybind11/2.10.4)
    endif()
endif()
list(PREPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/third_party")

include(GNUInstallDirs)
if(UNIX)
    set(CUPOCH_INSTALL_CMAKE_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
else()
    set(CUPOCH_INSTALL_CMAKE_DIR CMake)
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
if (NOT BUILD_SHARED_LIBS)
    set(CMAKE_C_VISIBILITY_PRESET hidden)
    set(CMAKE_CXX_VISIBILITY_PRESET hidden)
    set(CMAKE_CUDA_VISIBILITY_PRESET hidden)
    set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)
endif ()

if (WIN32)
    # can't hide the unit testing option on Windows only
    # as a precaution: disable unit testing on Windows regardless of user input
    message(STATUS "Disable unit tests since this feature is not fully supported on Windows.")
    set(BUILD_UNIT_TESTS OFF)
    set(USE_RMM OFF)
    add_definitions(-DWINDOWS)
    add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_NONSTDC_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS)		# suppress C4996 warning
    add_definitions(-DTHRUST_CPP11_REQUIRED_NO_ERROR)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    message(STATUS "Compiling on Windows")
    if (MSVC)
        message(STATUS "Compiling with MSVC")
        add_definitions(-DNOMINMAX)
        add_definitions(-D_USE_MATH_DEFINES)
        add_definitions(-D_ENABLE_EXTENDED_ALIGNED_STORAGE)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /EHsc /Zc:__cplusplus /bigobj")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /MP")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
    endif ()
    if (STATIC_WINDOWS_RUNTIME)
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    else ()
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
    endif ()
    message(STATUS "CMAKE_C_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE}")
    message(STATUS "CMAKE_C_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG}")
    message(STATUS "CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE}")
    message(STATUS "CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG}")
elseif (CYGWIN)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    message(STATUS "Compiling on Cygwin")
    add_definitions(-DCYGWIN)
    add_compile_options($<$<CONFIG:Debug>:-O3>)
elseif (UNIX OR APPLE)
    add_definitions(-DUNIX)
    add_compile_options(-Wno-deprecated-declarations)
    # In Release build -O3 will be added automatically by CMake
    # We still enable -O3 at Debug build to optimize performance
    add_compile_options($<$<CONFIG:Debug>:-O3>)
endif ()

if (INIT_ARCHITECTURES)
    include(cuda_architecture_macros)
    init_cmake_cuda_architectures()
    set(CMAKE_CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}"
        CACHE STRING "List of CUDA architectures to generate device code for" FORCE)
    set(INIT_ARCHITECTURES FALSE CACHE INTERNAL "")
endif()
message(STATUS "CMAKE_CUDA_ARCHITECTURES: ${CMAKE_CUDA_ARCHITECTURES}")

include(cupoch_cuda_flags)

include_directories(src)
add_subdirectory(src)
if (BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()
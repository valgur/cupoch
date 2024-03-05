if(DEFINED VCPKG_TOOLCHAIN)
  set(USE_CONAN_DEFAULT OFF)
else()
  set(USE_CONAN_DEFAULT ON)
endif()

string(FIND "${CMAKE_TOOLCHAIN_FILE}" "conan_toolchain.cmake" FOUND_CONAN_TOOLCHAIN)
if(FOUND_CONAN_TOOLCHAIN GREATER_EQUAL 0)
  set(BUILD_TRIGGERED_BY_CONAN TRUE)
endif()

option(USE_CONAN "Use Conan to automatically manage dependencies" ${USE_CONAN_DEFAULT})

if(USE_CONAN AND NOT BUILD_TRIGGERED_BY_CONAN)
  include(${CMAKE_CURRENT_LIST_DIR}/conan_dependencies.cmake)
  conan_dependencies_file(${CMAKE_SOURCE_DIR}/conanfile.py)
  if(BUILD_PYTHON_MODULE)
    conan_dependencies(pybind11/2.10.4)
  endif()
endif()

list(PREPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/third_party")

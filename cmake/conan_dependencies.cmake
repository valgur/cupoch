function(conan_dependencies_file)
  if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/conan.cmake")
    file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/0.18.1/conan.cmake"
      "${CMAKE_CURRENT_BINARY_DIR}/conan.cmake" TLS_VERIFY ON)
  endif()
  include(${CMAKE_CURRENT_BINARY_DIR}/conan.cmake)

  set(CONAN_UPDATE_DEPS ON CACHE BOOL
    "Install conan dependencies with --update set.
    Note that for dependencies that accept a version range, this will ignore any packages in the local cache.")
  set(update "")
  if(CONAN_UPDATE_DEPS)
    set(update "UPDATE")
  endif()

  conan_cmake_autodetect(conan_settings)
  message(STATUS "Conan autodetected settings: ${conan_settings}")

  conan_cmake_install(
    PATH_OR_REFERENCE ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_FOLDER ${CMAKE_CURRENT_BINARY_DIR}
    PROFILE_BUILD default
    PROFILE_HOST default
    ${update}
    BUILD missing
    SETTINGS ${conan_settings}
    # Set CC and CXX env vars for users who have overriden these in their default conan profile.
    # Otherwise the profile values take precedence over the compiler configured in ${conan_settings},
    # which will cause issues in case of a mismatch.
    ENV CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
  )

  # Update CMake config search paths for the "CMakeDeps" generator.
  # Prepend to prioritize conan packages over system ones.
  # Multiple paths are added due to the output directory of the generator depending on
  # the layout() config in the used conanfile.py.
  list(PREPEND CMAKE_PREFIX_PATH
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/build/generators
    ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/build/generators)
  set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
endfunction()

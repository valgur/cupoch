include(${CMAKE_CURRENT_LIST_DIR}/conan.cmake)

string(FIND "${CMAKE_TOOLCHAIN_FILE}" "conan_toolchain.cmake" FOUND_CONAN_TOOLCHAIN)
if(FOUND_CONAN_TOOLCHAIN GREATER_EQUAL 0)
    set(BUILD_TRIGGERED_BY_CONAN TRUE)
else()
    set(BUILD_TRIGGERED_BY_CONAN FALSE)
endif()

macro(conan_dependencies)
    if(${ARGC} LESS 1)
        message(WARNING "No packages passed to conan_dependencies")
    else()
        message(STATUS "Getting packages with conan: ${ARGN}")
        conan_cmake_configure(
            REQUIRES ${ARGN}
            GENERATORS CMakeDeps
        )
        _custom_conan_cmake_install(${CMAKE_CURRENT_BINARY_DIR})
    endif()
endmacro()

macro(conan_dependencies_file)
    message(STATUS "Getting packages with conan: ${CATKIN_CONAN_DEPS}")
    _custom_conan_cmake_install(${CMAKE_CURRENT_SOURCE_DIR})
    set(CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR} ${CMAKE_MODULE_PATH})
endmacro()

function(_custom_conan_cmake_install)
    # Make sure we are using a fairly recent version.
    conan_check(VERSION 1.44 REQUIRED)

    set(CONAN_UPDATE_DEPS ON CACHE BOOL
        "Install conan dependencies with --update set.
    Note that for dependencies that accept a version range, this will ignore any packages in the local cache.")
    set(update "")
    if(CONAN_UPDATE_DEPS)
        set(update "UPDATE")
    endif()

    # Get Conan profile from an env or CMake variable, use default otherwise.
    if(DEFINED ENV{CONAN_PROFILE})
        set(CONAN_PROFILE $ENV{CONAN_PROFILE})
    endif()
    if(DEFINED ENV{CONAN_BUILD_PROFILE})
        set(CONAN_BUILD_PROFILE $ENV{CONAN_BUILD_PROFILE})
    endif()
    if(DEFINED ENV{CONAN_HOST_PROFILE})
        set(CONAN_HOST_PROFILE $ENV{CONAN_HOST_PROFILE})
    endif()
    set(AUTODETECT_SETTINGS TRUE)
    if(DEFINED CONAN_PROFILE OR DEFINED CONAN_BUILD_PROFILE OR DEFINED CONAN_HOST_PROFILE)
        set(AUTODETECT_SETTINGS FALSE)
    endif()
    if(NOT DEFINED CONAN_PROFILE)
        set(CONAN_PROFILE default)
    endif()
    if(NOT DEFINED CONAN_BUILD_PROFILE)
        set(CONAN_BUILD_PROFILE ${CONAN_PROFILE})
    endif()
    if(NOT DEFINED CONAN_HOST_PROFILE)
        set(CONAN_HOST_PROFILE ${CONAN_PROFILE})
    endif()

    if(AUTODETECT_SETTINGS)
        conan_cmake_autodetect(conan_settings conan_conf)
        message(STATUS "Conan autodetected settings: '${conan_settings}'")
        message(STATUS "Conan autodetected conf : '${conan_conf}'")
        set(autodetected
            SETTINGS_BUILD ${conan_settings}
            SETTINGS_HOST ${conan_settings}
            CONF_BUILD ${conan_conf}
            CONF_HOST ${conan_conf}
            )
    endif()

    conan_cmake_install(
        PATH_OR_REFERENCE ${ARGV0}
        OUTPUT_FOLDER ${CMAKE_CURRENT_BINARY_DIR}
        PROFILE_BUILD ${CONAN_BUILD_PROFILE}
        PROFILE_HOST ${CONAN_HOST_PROFILE}
        BUILD missing
        ${update}
        ${autodetected}
    )

    # Update CMake config search paths for the "CMakeDeps" generator.
    # Prepend to prioritize conan packages over system ones.
    # Multiple paths are added due to the output directory of the generator depending on
    # the layout() config in the used conanfile.py.
    list(PREPEND CMAKE_PREFIX_PATH
        ${CMAKE_CURRENT_BINARY_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}/build/${CMAKE_BUILD_TYPE}/generators)
    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
endfunction()

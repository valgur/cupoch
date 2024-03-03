vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cccl
    REF "v${VERSION}"
    SHA512 40002962f4be97e2f6bccc677e5218818417f0918cba5a57373c5f4905aef21ec10dbd36f072cf319495a7d8b644677b8c86dd903a7bc6b5ec63ff8ea272ebdc
    HEAD_REF main
    PATCHES 001-fix-cmake-config-location.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libcudacxx"
    OPTIONS
        # TODO: add static library support
        -DLIBCUDACXX_ENABLE_STATIC_LIBRARY=OFF
        -DLIBCUDACXX_ENABLE_LIBCUDACXX_TESTS=OFF
        -DLIBCUDACXX_ENABLE_LIBCXX_TESTS=OFF
        -DLIBCUDACXX_ENABLE_LIBCXXABI_TESTS=OFF
        -DLIBCUDACXX_ENABLE_LIBUNWIND_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/libcudacxx/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/libcudacxx/LICENSE.TXT")

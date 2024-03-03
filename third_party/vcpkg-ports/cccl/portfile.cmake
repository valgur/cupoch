vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVIDIA/cccl
    REF "v${VERSION}"
    SHA512 40002962f4be97e2f6bccc677e5218818417f0918cba5a57373c5f4905aef21ec10dbd36f072cf319495a7d8b644677b8c86dd903a7bc6b5ec63ff8ea272ebdc
    HEAD_REF main
)

file(COPY "${SOURCE_PATH}/lib/cmake/cccl" DESTINATION "${CURRENT_PACKAGES_DIR}/share")
file(COPY "${SOURCE_PATH}/lib/cmake/cccl" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_cmake_config_fixup()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

set(VERSION 24.02.00)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rapidsai/rmm
    REF "v${VERSION}"
    SHA512 db1eee72e80a5cae8f965365c3ec3ee73f3a77407fbe291632fc6ab1c286f06400b219aa4668b8dd3d5f68ad0666df1b2ecafbc4ded3170a50b167d3ecbff469
    HEAD_REF main
    PATCHES 001-cmake-deps.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFETCHCONTENT_FULLY_DISCONNECTED=FALSE
        -DBUILD_TESTS=FALSE
        -DBUILD_BENCHMARKS=FALSE
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rmm)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_apply_patches(
    SOURCE_PATH "${CURRENT_PACKAGES_DIR}/share/rmm"
    PATCHES 002-config-deps.patch
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stotko/stdgpu
    REF 71a5aef26626eda47d15e5f577ca3b1538ff996a
    SHA512 b66aead19cf93d52a1fe10efcd93e51e0009aeed34e17b78a02b8fee8fe807dac4df10b7f14d0b145590f9b3d49ea66efa17fc76eba082a7f7111f1712220566
    HEAD_REF master
    PATCHES 001-fix-thrust-cmake.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

file(REMOVE "${SOURCE_PATH}/cmake/Findthrust.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        # TODO: add support for OpenMP and HIP backends via features
        -DSTDGPU_BACKEND=STDGPU_BACKEND_CUDA
        -DSTDGPU_BUILD_SHARED_LIBS=${BUILD_SHARED}
        -DSTDGPU_COMPILE_WARNING_AS_ERROR=FALSE
        -DSTDGPU_BUILD_EXAMPLES=FALSE
        -DSTDGPU_BUILD_BENCHMARKS=FALSE
        -DSTDGPU_BUILD_TESTS=FALSE
        -DSTDGPU_BUILD_TEST_COVERAGE=FALSE
        -DSTDGPU_ANALYZE_WITH_CLANG_TIDY=FALSE
        -DSTDGPU_ANALYZE_WITH_CPPCHECK=FALSE
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stdgpu)

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

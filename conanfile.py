import os

from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout

# for self.info.clear()
required_conan_version = ">=1.50.0"


class CupochConan(ConanFile):
    name = "cupoch"
    version = "0.2.6"
    package_type = "library"

    license = "MIT"
    author = "nekanat.stock@gmail.com"
    url = "https://github.com/neka-nat/cupoch"
    description = "Rapid 3D data processing for robotics using CUDA."

    settings = "os", "compiler", "build_type", "arch"
    options = {"shared": [True, False], "fPIC": [True, False]}
    default_options = {"shared": False, "fPIC": True}
    build_policy = "missing"

    exports_sources = ["include/*", "src/*", "cmake/*", "third_party/*", "CMakeLists.txt"]

    @property
    def _with_unit_tests(self):
        # Unit tests are not built or run by default.
        # Add '-c tools.build:skip_test=false' to command line args to enable.
        return not self.conf.get("tools.build:skip_test", default=True, check_type=bool)

    @property
    def _skip_build(self):
        return os.environ.get("SKIP_BUILD", "0") != "0"

    def requirements(self):
        self.requires("eigen/3.4.0", headers=True, transitive_headers=True)
        self.requires("spdlog/1.8.5", headers=True, libs=True)
        self.requires("dlpack/0.4", headers=True, libs=True)
        self.requires("jsoncpp/1.9.5", headers=True, libs=True)
        self.requires("tinyobjloader/1.0.7", headers=True, libs=True)
        self.requires("libpng/1.6.39", headers=True, libs=True)
        self.requires("libjpeg-turbo/2.1.4", headers=True, libs=True)
        self.requires("glew/2.2.0", headers=True, libs=True)
        self.requires("glfw/3.3.8", headers=True, libs=True)
        self.requires("imgui/1.89.1", headers=True, libs=True)

    def build_requirements(self):
        self.test_requires("gtest/1.12.1")
        self.test_requires("pybind11/2.10.1")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        # Do not set CXX, C flags from Conan to avoid adding -stdlib=libstdc++
        tc.blocks.remove("cmake_flags_init")
        tc.cache_variables["BUILD_TESTING"] = self._with_unit_tests
        # tc.preprocessor_definitions["FLANN_USE_CUDA"] = 1
        # tc.preprocessor_definitions["SPDLOG_FMT_EXTERNAL"] = 1
        tc.generate()
        CMakeDeps(self).generate()

    def build(self):
        if self._skip_build:
            return
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
        if self._with_unit_tests:
            cmake.test()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_id(self):
        if self._skip_build:
            # Treat the package as if it was header-only
            self.info.clear()

    def package_info(self):
        self.cpp_info.libs = [
            "cupoch_geometry",
            "cupoch_registration",
            "cupoch_utility",
            "flann_cuda_s",
        ]

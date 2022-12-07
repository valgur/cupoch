import os

from conan import ConanFile
from conan.tools.build import cross_building
from conan.tools.cmake import CMake, cmake_layout


class CupochTestPkg(ConanFile):
    test_type = "explicit"
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    @property
    def _skip_build(self):
        return os.environ.get("SKIP_BUILD", "0") != "0"

    def requirements(self):
        self.requires(self.tested_reference_str)

    def build(self):
        if self._skip_build:
            return
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def layout(self):
        cmake_layout(self)

    def test(self):
        if self._skip_build:
            return
        if not cross_building(self):
            cmd = os.path.join(self.cpp.build.bindirs[0], "example")
            self.run(cmd, env="conanrun")

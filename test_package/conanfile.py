import os

from conan import ConanFile
from conan.tools.build import can_run
from conan.tools.cmake import CMake, cmake_layout


class CupochTestPkg(ConanFile):
    test_type = "explicit"
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        self.requires(self.tested_reference_str)

    def layout(self):
        cmake_layout(self)

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def test(self):
        if not can_run(self):
            return
        cupoch_opts = self.dependencies["cupoch"].options
        if cupoch_opts.kinematics:
            cmd = os.path.join(self.cpp.build.bindir, "test_kinematics")
            self.run(cmd, env="conanrun")
        if cupoch_opts.imageproc and cupoch_opts.io:
            cmd = os.path.join(self.cpp.build.bindir, "test_imageproc")
            self.run(cmd, env="conanrun")
        if cupoch_opts.io:
            cmd = os.path.join(self.cpp.build.bindir, "test_io")
            self.run(cmd, env="conanrun")
        if cupoch_opts.registration:
            cmd = os.path.join(self.cpp.build.bindir, "test_registration")
            self.run(cmd, env="conanrun")
        if cupoch_opts.visualization:
            cmd = os.path.join(self.cpp.build.bindir, "test_visualization")
            self.run(cmd, env="conanrun")

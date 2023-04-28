import os

from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout
from conan.tools.files import copy

required_conan_version = ">=1.53.0"


class CupochConan(ConanFile):
    name = "cupoch"
    version = "0.2.7.2"
    package_type = "library"

    license = "MIT"
    author = "nekanat.stock@gmail.com"
    url = "https://github.com/neka-nat/cupoch"
    description = "Rapid 3D data processing for robotics using CUDA."

    settings = "os", "compiler", "build_type", "arch"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "use_rmm": [True, False],
    }
    default_options = {
        "shared": False,
        "fPIC": True,
        "use_rmm": True,
    }

    exports_sources = [
        "include/*",
        "src/*",
        "cmake/*",
        "examples/*",
        "scripts/*",
        "third_party/*",
        "CMakeLists.txt",
    ]

    @property
    def _with_unit_tests(self):
        # Unit tests are not built or run by default.
        # Add '-c tools.build:skip_test=false' to command line args to enable.
        return not self.conf.get("tools.build:skip_test", default=True, check_type=bool)

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC
            del self.options.use_rmm

    def configure(self):
        if self.options.shared:
            del self.options.fPIC

    def requirements(self):
        self.requires("dlpack/0.4", headers=True, libs=True)
        self.requires("eigen/3.4.0", transitive_headers=True, transitive_libs=True)
        self.requires("glew/2.2.0", headers=True, libs=True)
        self.requires("glfw/3.3.8", headers=True, libs=True)
        self.requires("imgui/1.89.4", headers=True, libs=True)
        self.requires("jsoncpp/1.9.5", headers=True, libs=True)
        self.requires("libjpeg-turbo/2.1.5", headers=True, libs=True)
        self.requires("libpng/1.6.39", headers=True, libs=True)
        self.requires("rply/1.1.4", headers=True, libs=True)
        self.requires("spdlog/1.11.0", transitive_headers=True, transitive_libs=True)
        self.requires("tinyobjloader/1.0.7", headers=True, libs=True)
        # https://github.com/conan-io/conan-center-index/pull/17282
        # self.requires("liblzf/3.6", headers=True, libs=True)

    def build_requirements(self):
        self.test_requires("gtest/1.13.0")
        self.test_requires("pybind11/2.10.1")

    def layout(self):
        cmake_layout(self)

    def source(self):
        # The imgui backends are not built by default and need to be copied to the source tree
        imgui_paths = self.dependencies["imgui/1.89.4"].cpp_info.srcdirs
        backends_dir = next(path for path in imgui_paths if path.endswith("bindings"))
        output_dir = os.path.join(
            self.source_folder, "src/cupoch/visualization/visualizer/imgui/backends"
        )
        for backend_file in [
            "imgui_impl_glfw.h",
            "imgui_impl_glfw.cpp",
            "imgui_impl_opengl3.h",
            "imgui_impl_opengl3_loader.h",
            "imgui_impl_opengl3.cpp",
        ]:
            copy(self, backend_file, backends_dir, output_dir)

    def generate(self):
        tc = CMakeToolchain(self)
        # Do not set CXX, C flags from Conan to avoid adding -stdlib=libstdc++
        tc.blocks.remove("cmake_flags_init")
        tc.variables["BUILD_UNIT_TESTS"] = self._with_unit_tests
        tc.variables["BUILD_EXAMPLES"] = False
        tc.variables["BUILD_PYTHON_MODULE"] = False
        tc.variables["USE_RMM"] = self.options.use_rmm
        tc.generate()
        CMakeDeps(self).generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
        if self._with_unit_tests:
            cmake.test()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        # components
        self.cpp_info.libs = [
            "cupoch_camera",
            "cupoch_collision",
            "cupoch_geometry",
            "cupoch_imageproc",
            "cupoch_integration",
            "cupoch_io",
            "cupoch_kinematics",
            "cupoch_kinfu",
            "cupoch_knn",
            "cupoch_odometry",
            "cupoch_planning",
            "cupoch_registration",
            "cupoch_utility",
            "cupoch_visualization",
        ]
        # third-party libs
        self.cpp_info.libs += [
            "flann_cuda_s",
            "liblzf",
            "console_bridge",
            "urdfdom",
            "sgm",
        ]
        self.cpp_info.defines.append("FLANN_USE_CUDA")
        if self.settings.os == "Windows":
            self.cpp_info.append("WINDOWS")
            self.cpp_info.append("_CRT_SECURE_NO_DEPRECATE")
            self.cpp_info.append("_CRT_NONSTDC_NO_DEPRECATE")
            self.cpp_info.append("_SCL_SECURE_NO_WARNINGS")
            self.cpp_info.append("GLEW_STATIC")
            self.cpp_info.append("THRUST_CPP11_REQUIRED_NO_ERROR")
            self.cpp_info.append("NOMINMAX")
            self.cpp_info.append("_USE_MATH_DEFINES")

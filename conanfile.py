import os
from pathlib import Path

from conan import ConanFile
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout
from conan.tools.files import copy, rm

required_conan_version = ">=1.53.0"

MODULE_DEPS = {
    "camera": [],
    "collision": ["geometry"],
    "geometry": ["camera", "knn"],
    "imageproc": ["geometry"],
    "integration": ["camera", "geometry"],
    "io": ["geometry"],
    "kinematics": ["collision", "io"],
    "kinfu": ["camera", "geometry", "integration", "registration"],
    "knn": [],
    "odometry": ["camera", "geometry"],
    "planning": ["collision", "geometry"],
    "registration": ["geometry", "knn"],
    "visualization": ["camera", "geometry", "io"],
}
MODULES = sorted(MODULE_DEPS)


class CupochConan(ConanFile):
    name = "cupoch"
    version = "0.2.8.1"
    package_type = "library"

    license = "MIT"
    author = "nekanat.stock@gmail.com"
    url = "https://github.com/neka-nat/cupoch"
    description = "Rapid 3D data processing for robotics using CUDA."

    settings = "os", "compiler", "build_type", "arch"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "cuda_architectures": [None, "ANY"],
        "use_rmm": [True, False],
    }
    options.update({module: [True, False] for module in MODULES})

    default_options = {
        "shared": False,
        "fPIC": True,
        "cuda_architectures": None,
        "use_rmm": True,
    }
    default_options.update({module: True for module in MODULES})

    exports = ["third_party/conan-recipes/*"]
    exports_sources = [
        "cmake/*",
        "include/*",
        "src/cupoch/*",
        "src/tests/*",
        "src/CMakeLists.txt",
        "scripts/*",
        "third_party/*",
        "CMakeLists.txt",
        "LICENSE",
    ]

    @property
    def _enabled_modules(self):
        # The list of requested modules together with their dependencies
        def add_deps(modules):
            for dep in modules:
                if dep not in mods:
                    mods.add(dep)
                    add_deps(MODULE_DEPS[dep])

        if not hasattr(self, "_enabled_modules_cache"):
            mods = set()
            add_deps([mod for mod in MODULES if self.options.get_safe(mod, False)])
            self._enabled_modules_cache = sorted(mods)
        return self._enabled_modules_cache

    @property
    def _with_unit_tests(self):
        # Unit tests are not built or run by default.
        # Add '-c tools.build:skip_test=false' to command line args to enable.
        return not self.conf.get("tools.build:skip_test", default=True, check_type=bool)

    def _export_local_recipes(self):
        self.output.info(
            "Exporting recipes for dependencies that are not yet available in ConanCenter"
        )
        recipes_root = Path(self.recipe_folder) / "third_party" / "conan-recipes"
        for pkg_dir in recipes_root.iterdir():
            if pkg_dir.is_dir():
                self.run(f"conan export {pkg_dir} --user cupoch")

    def export_sources(self):
        self._export_local_recipes()

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC
            del self.options.use_rmm

    def configure(self):
        if self.options.shared:
            del self.options.fPIC
        self.options["thrust"].device_system = "cuda"
        self.options["stdgpu"].backend = "cuda"

    def package_id(self):
        for module in self._enabled_modules:
            setattr(self.info.options, module, True)

    def requirements(self):
        # Used by all modules via cupoch_utility
        self.requires("eigen/3.4.90-20230718@cupoch", transitive_headers=True)
        self.requires("spdlog/1.11.0", transitive_headers=True)
        self.requires("thrust/1.16.0", transitive_headers=True, force=True)
        self.requires("stdgpu/cci.20230507@cupoch", transitive_headers=True)
        self.requires("dlpack/0.4")
        self.requires("jsoncpp/1.9.5")
        self.requires("fmt/10.0.0", override=True)

        if self.options.get_safe("use_rmm"):
            self.requires("rmm/23.06.00", transitive_headers=True)

        modules = self._enabled_modules
        self.output.info("Enabled modules:", modules)
        if "imageproc" in modules:
            self.requires("libsgm/3.0.0@cupoch")
        if "io" in modules:
            self.requires("libjpeg-turbo/3.0.0")
            self.requires("libpng/1.6.40")
            self.requires("rply/1.1.4")
            self.requires("tinyobjloader/2.0.0-rc10")
            self.requires("liblzf/3.6")
        if "kinematics" in modules:
            self.requires("urdfdom/3.1.1@cupoch")
        if "visualization" in modules:
            self.requires("glew/2.2.0")
            self.requires("glfw/3.3.8")
            self.requires("imgui/1.89.7")

    def build_requirements(self):
        self.test_requires("gtest/1.13.0")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        # Do not set CXX, C flags from Conan to avoid adding -stdlib=libstdc++
        tc.blocks.remove("cmake_flags_init")
        tc.cache_variables["BUILD_UNIT_TESTS"] = self._with_unit_tests
        tc.cache_variables["BUILD_EXAMPLES"] = False
        tc.cache_variables["BUILD_PYTHON_MODULE"] = False
        tc.cache_variables["USE_RMM"] = self.options.get_safe("use_rmm", False)
        if self.options.cuda_architectures is not None:
            tc.cache_variables["CMAKE_CUDA_ARCHITECTURES"] = self.options.cuda_architectures
        for module in MODULES:
            tc.cache_variables[f"BUILD_cupoch_{module}"] = module in self._enabled_modules
        tc.generate()

        deps = CMakeDeps(self)
        # Make find_package() fail if any required components are missing
        deps.check_components_exist = True
        deps.generate()

    def _copy_imgui_backends(self):
        # The imgui backends are not built by default and need to be copied to the source tree
        backends_dir = Path(self.dependencies["imgui"].package_folder) / "res" / "bindings"
        output_dir = self.source_path / "src/cupoch/visualization/visualizer/imgui/backends"
        for backend_file in [
            "imgui_impl_glfw.h",
            "imgui_impl_glfw.cpp",
            "imgui_impl_opengl3.h",
            "imgui_impl_opengl3_loader.h",
            "imgui_impl_opengl3.cpp",
        ]:
            copy(self, backend_file, backends_dir, output_dir)

    def build(self):
        if "visualization" in self._enabled_modules:
            self._copy_imgui_backends()
        cmake = CMake(self)
        cmake.configure()
        cmake.build()
        if self._with_unit_tests:
            cmake.test()

    def package(self):
        cmake = CMake(self)
        cmake.install()
        copy(self, "configure_cuda.cmake",
             dst=self.package_path / "lib" / "cmake",
             src=self.source_path / "cmake")
        copy(self, "LICENSE",
             dst=self.package_path / "licenses",
             src=self.source_path)
        rm(self, "*.pdb", self.package_path, recursive=True)

    def _module_reqs(self, component):
        reqs = {
            "utility": [
                "eigen::eigen",
                "spdlog::spdlog",
                "thrust::thrust",
                "stdgpu::stdgpu",
                "dlpack::dlpack",
                "jsoncpp::jsoncpp",
            ],
            "imageproc": [
                "libsgm::libsgm",
            ],
            "io": [
                "libjpeg-turbo::libjpeg-turbo",
                "libpng::libpng",
                "rply::rply",
                "tinyobjloader::tinyobjloader",
                "liblzf::liblzf",
            ],
            "kinematics": [
                "urdfdom::urdfdom",
            ],
            "visualization": [
                "glew::glew",
                "glfw::glfw",
                "imgui::imgui",
            ],
        }
        return reqs.get(component, [])

    def package_info(self):
        for module in self._enabled_modules + ["utility"]:
            component = self.cpp_info.components[module]
            component.libs += [f"cupoch_{module}"]
            component.defines.append(f"CUPOCH_{module.upper()}_ENABLED")
            component.requires = MODULE_DEPS.get(module, [])
            component.requires += self._module_reqs(module)
            if module != "utility":
                component.requires.append("utility")
            self.cpp_info.components["cupoch"].requires.append(module)

        if "knn" in self._enabled_modules:
            self.cpp_info.components["flann_cuda"].libs = ["flann_cuda_s"]
            self.cpp_info.components["flann_cuda"].defines = ["FLANN_USE_CUDA"]
            self.cpp_info.components["knn"].requires.append("flann_cuda")

        if self.options.get_safe("use_rmm"):
            self.cpp_info.components["utility"].requires.append("rmm::rmm")

        # Propagate necessary build flags
        utility = self.cpp_info.components["utility"]
        utility.defines.append("_USE_MATH_DEFINES")
        if self.settings.os == "Windows":
            utility.cxxflags += ["/EHsc", "/Zc:__cplusplus", "/bigobj"]
            utility.defines.append("_ENABLE_EXTENDED_ALIGNED_STORAGE")
            utility.defines.append("_CRT_SECURE_NO_DEPRECATE")
            utility.defines.append("_CRT_NONSTDC_NO_DEPRECATE")
            utility.defines.append("_SCL_SECURE_NO_WARNINGS")
            utility.defines.append("THRUST_CPP11_REQUIRED_NO_ERROR")
            utility.defines.append("NOMINMAX")

        # Export CUDA dependencies and flags
        self.cpp_info.set_property("cmake_build_modules", [os.path.join("lib", "cmake", "configure_cuda.cmake")])

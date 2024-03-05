import os

from conan import ConanFile
from conan.tools.build import check_min_cppstd
from conan.tools.cmake import CMake, CMakeDeps, CMakeToolchain, cmake_layout
from conan.tools.files import apply_conandata_patches, copy, export_conandata_patches, get, rm

required_conan_version = ">=1.53.0"


class LibSGMConan(ConanFile):
    name = "libsgm"
    version = "3.1.0"
    description = "Stereo Semi-Global Matching with CUDA"
    license = "Apache-2.0"
    url = ""
    homepage = "https://github.com/fixstars/libSGM"
    topics = ("stereo", "depth", "sgm", "cuda")
    package_type = "library"
    settings = "os", "arch", "compiler", "build_type"
    options = {
        "shared": [True, False],
        "fPIC": [True, False],
        "cuda_architectures": ["ANY"],
    }
    default_options = {
        "shared": False,
        "fPIC": True,
        "cuda_architectures": "61",
    }

    @property
    def _min_cppstd(self):
        return 17

    def export_sources(self):
        export_conandata_patches(self)

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def configure(self):
        if self.options.shared:
            self.options.rm_safe("fPIC")

    def layout(self):
        cmake_layout(self, src_folder="src")

    def requirements(self):
        pass

    def validate(self):
        if self.settings.compiler.cppstd:
            check_min_cppstd(self, self._min_cppstd)

    def source(self):
        get(self, **self.conan_data["sources"][self.version], strip_root=True)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.variables["LIBSGM_SHARED"] = self.options.shared
        tc.variables["CUDA_ARCHS"] = self.options.cuda_architectures
        tc.generate()
        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        apply_conandata_patches(self)
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(
            self,
            pattern="LICENSE",
            dst=os.path.join(self.package_folder, "licenses"),
            src=self.source_folder,
        )
        cmake = CMake(self)
        cmake.install()
        rm(self, "*.pdb", self.package_folder)

    def package_info(self):
        self.cpp_info.libs = ["sgm"]
        self.cpp_info.set_property("cmake_file_name", "LibSGM")
        self.cpp_info.set_property("cmake_target_name", "LibSGM::sgm")

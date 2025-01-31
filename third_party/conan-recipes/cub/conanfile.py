import os

from conan import ConanFile
from conan.errors import ConanInvalidConfiguration
from conan.tools.build import check_min_cppstd
from conan.tools.files import copy, get, move_folder_contents
from conan.tools.layout import basic_layout
from conan.tools.scm import Version

required_conan_version = ">=1.52.0"


class CubConan(ConanFile):
    name = "cub"
    version = "2.2.0"
    description = "Cooperative primitives for CUDA C++"
    license = "BSD 3-Clause"
    url = "https://github.com/conan-io/conan-center-index"
    homepage = "https://github.com/NVIDIA/cccl/tree/main/cub"
    topics = ("algorithms", "cuda", "gpu", "nvidia", "nvidia-hpc-sdk", "header-only")

    package_type = "header-library"
    settings = "os", "arch", "compiler", "build_type"
    no_copy_source = True

    @property
    def _min_cppstd(self):
        return 14

    @property
    def _compilers_minimum_version(self):
        return {
            "Visual Studio": "15",
            "msvc": "191",
            "gcc": "5",
            "clang": "5",
            "apple-clang": "5.1",
        }

    def layout(self):
        basic_layout(self, src_folder="src")

    def package_id(self):
        self.info.clear()

    def requirements(self):
        if Version(self.version) >= "2.0":
            self.requires(f"libcudacxx/{self.version}")

    def validate(self):
        if self.settings.compiler.get_safe("cppstd"):
            check_min_cppstd(self, self._min_cppstd)
        minimum_version = self._compilers_minimum_version.get(str(self.settings.compiler), False)
        if minimum_version and Version(self.settings.compiler.version) < minimum_version:
            raise ConanInvalidConfiguration(
                f"{self.ref} requires C++{self._min_cppstd}, which your compiler does not support."
            )

    def source(self):
        get(self, **self.conan_data["sources"][self.version], strip_root=True)

    @property
    def _source_subfolder(self):
        if Version(self.version) >= "2.0":
            return os.path.join(self.source_folder, "cub")
        return self.source_folder

    def package(self):
        copy(self, "LICENSE.TXT",
             dst=os.path.join(self.package_folder, "licenses"),
             src=self._source_subfolder)
        copy(self, "*.cuh",
             dst=os.path.join(self.package_folder, "include", "cub"),
             src=os.path.join(self._source_subfolder, "cub"))

    def package_info(self):
        self.cpp_info.bindirs = []
        self.cpp_info.frameworkdirs = []
        self.cpp_info.libdirs = []
        self.cpp_info.resdirs = []

        # Follows the naming conventions of the official CMake config file:
        # https://github.com/NVIDIA/cub/blob/main/cub/cmake/cub-config.cmake
        self.cpp_info.set_property("cmake_file_name", "cub")
        self.cpp_info.set_property("cmake_target_name", "CUB::CUB")

        # TODO: to remove in conan v2 once cmake_find_package_* generators removed
        self.cpp_info.filenames["cmake_find_package"] = "cub"
        self.cpp_info.filenames["cmake_find_package_multi"] = "cub"
        self.cpp_info.names["cmake_find_package"] = "CUB"
        self.cpp_info.names["cmake_find_package_multi"] = "CUB"

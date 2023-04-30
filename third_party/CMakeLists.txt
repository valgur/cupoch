# flann
file(GLOB_RECURSE CU_SOURCES flann/*.cu)
add_library(flann_cuda_s STATIC ${CU_SOURCES})
add_library(flann::flann_cuda_s ALIAS flann_cuda_s)
target_include_directories(flann_cuda_s PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/flann>)
target_compile_definitions(flann_cuda_s PUBLIC FLANN_USE_CUDA)
target_link_libraries(flann_cuda_s PRIVATE cupoch_flags CUDA::cudart spdlog::spdlog rmm::rmm)
install(TARGETS flann_cuda_s)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/flann/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")

# liblzf
enable_language(C)
file(GLOB LIBLZF_SOURCE_FILES "liblzf/*.c")
add_library(liblzf ${LIBLZF_SOURCE_FILES})
add_library(liblzf::liblzf ALIAS liblzf)
target_include_directories(liblzf PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/liblzf>
    $<INSTALL_INTERFACE:liblzf>)
set_target_properties(liblzf PROPERTIES LINKER_LANGUAGE C)
install(TARGETS liblzf)
#install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/liblzf
#    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
#    FILES_MATCHING PATTERN "*.h")

# tritriintersect
add_library(tomasakeninemoeller INTERFACE)
add_library(tomasakeninemoeller::tritriintersect ALIAS tomasakeninemoeller)
target_include_directories(tomasakeninemoeller INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/tritriintersect>
    $<INSTALL_INTERFACE:tritriintersect>
)
install(TARGETS tomasakeninemoeller)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tritriintersect
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/tritriintersect
    FILES_MATCHING PATTERN "*.h")

# stdgpu
set(STDGPU_BUILD_EXAMPLES OFF CACHE INTERNAL "")
set(STDGPU_BUILD_TESTS OFF CACHE INTERNAL "")
set(STDGPU_BUILD_BENCHMARKS OFF CACHE INTERNAL "")
set(STDGPU_SETUP_COMPILER_FLAGS OFF CACHE INTERNAL "")
add_subdirectory(stdgpu)
set_target_properties(stdgpu PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(stdgpu INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/stdgpu/src>)
#install(TARGETS stdgpu)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/stdgpu/src/stdgpu
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.cpp" EXCLUDE PATTERN "*.txt" EXCLUDE)

# rply
enable_language(C)
add_library(rply rply/rply.c)
add_library(rply::rply ALIAS rply)
set_target_properties(rply PROPERTIES LINKER_LANGUAGE C)
target_include_directories(rply INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/rply>
    $<INSTALL_INTERFACE:rply>)
install(TARGETS rply)
#install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rply
#    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
#    FILES_MATCHING PATTERN "*.h")

# rmm
add_library(rmm INTERFACE)
add_library(rmm::rmm ALIAS rmm)
target_include_directories(rmm INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/rmm/include>)
target_link_libraries(rmm INTERFACE spdlog::spdlog)
target_compile_features(rmm INTERFACE cxx_std_17 $<BUILD_INTERFACE:cuda_std_17>)
install(TARGETS rmm)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rmm/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# lbvh
add_library(lbvh INTERFACE)
add_library(lbvh::lbvh ALIAS lbvh)
target_include_directories(lbvh INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lbvh>)
install(TARGETS lbvh)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lbvh/lbvh DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# lbvh_index
add_library(lbvh_index INTERFACE)
add_library(lbvh::lbvh_index ALIAS lbvh_index)
target_include_directories(lbvh_index INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lbvh_index>)
install(TARGETS lbvh_index)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lbvh_index/lbvh_index DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

## urdfdom
set(CONSOLE_BRIDGE_MAJOR_VERSION 1)
set(CONSOLE_BRIDGE_MINOR_VERSION 0)
set(CONSOLE_BRIDGE_PATCH_VERSION 1)
add_library(console_bridge urdfdom/urdf_parser/src/console.cpp)
set_target_properties(console_bridge PROPERTIES SOVERSION
    ${CONSOLE_BRIDGE_MAJOR_VERSION}.${CONSOLE_BRIDGE_MINOR_VERSION})
target_include_directories(console_bridge PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/urdfdom/urdf_parser/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>)
include(GenerateExportHeader)
generate_export_header(console_bridge EXPORT_MACRO_NAME CONSOLE_BRIDGE_DLLAPI)

file(GLOB_RECURSE URDFDOM_SOURCES urdfdom/urdf_parser/src/*.cpp)
list(REMOVE_ITEM URDFDOM_SOURCES "urdfdom/urdf_parser/src/console.cpp")
add_library(urdfdom STATIC ${URDFDOM_SOURCES})
add_library(urdfdom::urdfdom ALIAS urdfdom)
target_include_directories(urdfdom PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/urdfdom/urdf_parser/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/urdfdom/urdf_parser/include/tinyxml>
    $<INSTALL_INTERFACE:tinyxml>)
target_link_libraries(urdfdom PRIVATE console_bridge)
install(TARGETS urdfdom console_bridge)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/urdfdom/urdf_parser/include/urdf_parser DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/urdfdom/urdf_parser/include/tinyxml DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

# libSGM
set(libSGM_VERSION_MAJOR 2)
set(libSGM_VERSION_MINOR 7)
set(libSGM_VERSION_PATCH 0)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/libSGM/include/libsgm_config.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/libSGM/include/libsgm_config.h)
file(GLOB SGM_SRCS "libSGM/src/*.cu" "libSGM/src/*.cpp")
add_library(sgm ${SGM_SRCS})
add_library(sgm::sgm ALIAS sgm)
target_include_directories(sgm PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/libSGM/include>)
target_link_libraries(sgm PRIVATE cupoch_flags CUDA::cudart)
install(TARGETS sgm)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/libSGM/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.h")

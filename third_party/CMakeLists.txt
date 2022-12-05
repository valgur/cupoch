# flann
file(GLOB_RECURSE CU_SOURCES flann/*.cu)
add_library(flann_cuda_s STATIC ${CU_SOURCES})
add_library(flann::flann_cuda_s ALIAS flann_cuda_s)
target_include_directories(flann_cuda_s PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}")
target_compile_definitions(flann_cuda_s PUBLIC FLANN_USE_CUDA)
target_link_libraries(flann_cuda_s PRIVATE cupoch_flags CUDA::cudart spdlog::spdlog rmm::rmm)

# liblzf
enable_language(C)
file(GLOB LIBLZF_SOURCE_FILES "liblzf/*.c")
add_library(liblzf ${LIBLZF_SOURCE_FILES})
add_library(liblzf::liblzf ALIAS liblzf)
target_include_directories(liblzf PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/liblzf>
    $<INSTALL_INTERFACE:liblzf>)
set_target_properties(liblzf PROPERTIES LINKER_LANGUAGE C)

# tritriintersect
add_library(tomasakeninemoeller INTERFACE)
add_library(tomasakeninemoeller::tritriintersect ALIAS tomasakeninemoeller)
target_include_directories(tomasakeninemoeller INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)

# stdgpu
set(STDGPU_BUILD_EXAMPLES OFF CACHE INTERNAL "")
set(STDGPU_BUILD_TESTS OFF CACHE INTERNAL "")
set(STDGPU_BUILD_BENCHMARKS OFF CACHE INTERNAL "")
set(STDGPU_SETUP_COMPILER_FLAGS OFF CACHE INTERNAL "")
add_subdirectory(stdgpu)
set_target_properties(stdgpu PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(stdgpu INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/stdgpu/src>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/stdgpu/src/stdgpu/include>
    $<INSTALL_INTERFACE:stdgpu/src>
    $<INSTALL_INTERFACE:stdgpu/src/stdgpu/include>)

# rply
enable_language(C)
add_library(rply rply/rply.c)
add_library(rply::rply ALIAS rply)
set_target_properties(rply PROPERTIES LINKER_LANGUAGE C)
target_include_directories(rply INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/rply>
    $<INSTALL_INTERFACE:rply>)

# rmm
add_library(rmm INTERFACE)
add_library(rmm::rmm ALIAS rmm)
target_include_directories(rmm INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/rmm/include>
    $<INSTALL_INTERFACE:rmm/include>)
target_link_libraries(rmm INTERFACE spdlog::spdlog)
target_compile_features(rmm INTERFACE cxx_std_17 $<BUILD_INTERFACE:cuda_std_17>)

# lbvh
add_library(lbvh INTERFACE)
add_library(lbvh::lbvh ALIAS lbvh)
target_include_directories(lbvh INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lbvh>
    $<INSTALL_INTERFACE:lbvh>)

# lbvh_index
add_library(lbvh_index INTERFACE)
add_library(lbvh::lbvh_index ALIAS lbvh_index)
target_include_directories(lbvh_index INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/lbvh_index>
    $<INSTALL_INTERFACE:lbvh_index>)

## urdfdom
set(CONSOLE_BRIDGE_MAJOR_VERSION 1)
set(CONSOLE_BRIDGE_MINOR_VERSION 0)
set(CONSOLE_BRIDGE_PATCH_VERSION 1)
add_library(console_bridge urdfdom/urdf_parser/src/console.cpp)
set_target_properties(console_bridge PROPERTIES SOVERSION
    ${CONSOLE_BRIDGE_MAJOR_VERSION}.${CONSOLE_BRIDGE_MINOR_VERSION})
target_include_directories(console_bridge PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/urdfdom/urdf_parser/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
    $<INSTALL_INTERFACE:include>)
include(GenerateExportHeader)
generate_export_header(console_bridge EXPORT_MACRO_NAME CONSOLE_BRIDGE_DLLAPI)

file(GLOB_RECURSE URDFDOM_SOURCES urdfdom/urdf_parser/src/*.cpp)
list(REMOVE_ITEM URDFDOM_SOURCES "urdfdom/urdf_parser/src/console.cpp")
add_library(urdfdom STATIC ${URDFDOM_SOURCES})
add_library(urdfdom::urdfdom ALIAS urdfdom)
target_include_directories(urdfdom PRIVATE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/urdfdom/urdf_parser/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/urdfdom/urdf_parser/include/tinyxml>
    $<INSTALL_INTERFACE:urdfdom/urdf_parser/include/tinyxml>
    $<INSTALL_INTERFACE:urdfdom/urdf_parser/include>)
target_link_libraries(urdfdom console_bridge)

# libSGM
set(libSGM_VERSION_MAJOR 2)
set(libSGM_VERSION_MINOR 7)
set(libSGM_VERSION_PATCH 0)
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/libSGM/include/libsgm_config.h.in
    ${CMAKE_CURRENT_SOURCE_DIR}/libSGM/include/libsgm_config.h
    )
file(GLOB SGM_SRCS "libSGM/src/*.cu" "libSGM/src/*.cpp")
add_library(sgm ${SGM_SRCS})
add_library(sgm::sgm ALIAS sgm)
target_include_directories(sgm PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/libSGM/include)
target_include_directories(sgm PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/libSGM/include>
    $<INSTALL_INTERFACE:libSGM/include>)
target_link_libraries(sgm PUBLIC cupoch_flags CUDA::cudart)


#install(TARGETS
#        ${FLANN_LIBRARIES}
#        ${GLEW_LIBRARIES}
#        ${glfw_LIBRARIES}
#        ${JPEG_TURBO_LIBRARIES}
#        ${PNG_LIBRARIES}
#        ${liblzf_LIBRARIES}
#        ${rply_LIBRARIES}
#        ${stdgpu_LIBRARIES}
#        ${SGM_LIBRARIES}
#        ${googletest_LIBRARIES}
#        ${imgui_LIBRARIES}
#        ${urdfdom_LIBRARIES}
#    EXPORT ${PROJECT_NAME}3rdTargets
#    RUNTIME DESTINATION ${CUPOCH_INSTALL_BIN_DIR}
#    LIBRARY DESTINATION ${CUPOCH_INSTALL_LIB_DIR}
#    ARCHIVE DESTINATION ${CUPOCH_INSTALL_LIB_DIR}
#)

#install(DIRECTORY
#        ${rmm_INCLUDE_DIRS}
#        ${stdgpu_INCLUDE_DIRS}
#        ${SGM_INCLUDE_DIRS}
#    DESTINATION ${CUPOCH_INSTALL_INCLUDE_DIR}/../
#)

if(TARGET sgm::sgm)
  return()
endif()

set(sgm_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/libSGM)

set(libSGM_VERSION_MAJOR 2)
set(libSGM_VERSION_MINOR 7)
set(libSGM_VERSION_PATCH 0)
configure_file(${sgm_SOURCE_DIR}/include/libsgm_config.h.in
  ${sgm_SOURCE_DIR}/include/libsgm_config.h)
file(GLOB SGM_SRCS
  "${sgm_SOURCE_DIR}/src/*.cu"
  "${sgm_SOURCE_DIR}/src/*.cpp"
)
add_library(sgm ${SGM_SRCS})
add_library(sgm::sgm ALIAS sgm)
target_include_directories(sgm PUBLIC $<BUILD_INTERFACE:${sgm_SOURCE_DIR}/include>)
target_link_libraries(sgm PRIVATE cupoch_flags CUDA::cudart)
install(TARGETS sgm)
install(DIRECTORY ${sgm_SOURCE_DIR}/include/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  FILES_MATCHING PATTERN "*.h")

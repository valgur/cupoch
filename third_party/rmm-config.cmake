if(TARGET rmm::rmm)
  return()
endif()

set(rmm_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/rmm)

find_package(spdlog REQUIRED CONFIG)
add_library(rmm INTERFACE)
add_library(rmm::rmm ALIAS rmm)
target_include_directories(rmm INTERFACE $<BUILD_INTERFACE:${rmm_SOURCE_DIR}/include>)
target_link_libraries(rmm INTERFACE spdlog::spdlog)
target_compile_features(rmm INTERFACE cxx_std_17 $<BUILD_INTERFACE:cuda_std_17>)
install(TARGETS rmm)
install(DIRECTORY ${rmm_SOURCE_DIR}/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

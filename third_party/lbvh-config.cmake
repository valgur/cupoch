if(TARGET lbvh::lbvh)
  return()
endif()

set(lbvh_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/lbvh)
set(lbvh_index_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/lbvh_index)

add_library(lbvh INTERFACE)
add_library(lbvh::lbvh ALIAS lbvh)
target_include_directories(lbvh INTERFACE $<BUILD_INTERFACE:${lbvh_SOURCE_DIR}>)
install(TARGETS lbvh)
install(DIRECTORY ${lbvh_SOURCE_DIR}/lbvh DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

add_library(lbvh_index INTERFACE)
add_library(lbvh::lbvh_index ALIAS lbvh_index)
target_include_directories(lbvh_index INTERFACE $<BUILD_INTERFACE:${lbvh_index_SOURCE_DIR}>)
install(TARGETS lbvh_index)
install(DIRECTORY ${lbvh_index_SOURCE_DIR}/lbvh_index DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

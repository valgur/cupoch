if(TARGET urdfdom::urdfdom)
  return()
endif()

set(urdfdom_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/urdfdom)

set(CONSOLE_BRIDGE_MAJOR_VERSION 1)
set(CONSOLE_BRIDGE_MINOR_VERSION 0)
set(CONSOLE_BRIDGE_PATCH_VERSION 1)
add_library(console_bridge ${urdfdom_SOURCE_DIR}/urdf_parser/src/console.cpp)
set_target_properties(console_bridge PROPERTIES SOVERSION
  ${CONSOLE_BRIDGE_MAJOR_VERSION}.${CONSOLE_BRIDGE_MINOR_VERSION})
target_include_directories(console_bridge PUBLIC
  $<BUILD_INTERFACE:${urdfdom_SOURCE_DIR}/urdf_parser/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>)
include(GenerateExportHeader)
generate_export_header(console_bridge EXPORT_MACRO_NAME CONSOLE_BRIDGE_DLLAPI)

file(GLOB_RECURSE URDFDOM_SOURCES ${urdfdom_SOURCE_DIR}/urdf_parser/src/*.cpp)
list(REMOVE_ITEM URDFDOM_SOURCES "${urdfdom_SOURCE_DIR}/urdf_parser/src/console.cpp")
add_library(urdfdom STATIC ${URDFDOM_SOURCES})
add_library(urdfdom::urdfdom ALIAS urdfdom)
target_include_directories(urdfdom PUBLIC
  $<BUILD_INTERFACE:${urdfdom_SOURCE_DIR}/urdf_parser/include>
  $<BUILD_INTERFACE:${urdfdom_SOURCE_DIR}/urdf_parser/include/tinyxml>
  $<INSTALL_INTERFACE:tinyxml>)
target_link_libraries(urdfdom PRIVATE console_bridge)
install(TARGETS urdfdom console_bridge)
install(DIRECTORY ${urdfdom_SOURCE_DIR}/urdf_parser/include/urdf_parser DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(DIRECTORY ${urdfdom_SOURCE_DIR}/urdf_parser/include/tinyxml DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

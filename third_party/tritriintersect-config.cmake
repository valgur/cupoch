if(TARGET tritriintersect::tritriintersect)
  return()
endif()

set(tritriintersect_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/tritriintersect)

add_library(tritriintersect INTERFACE)
add_library(tritriintersect::tritriintersect ALIAS tritriintersect)
target_include_directories(tritriintersect INTERFACE
  $<BUILD_INTERFACE:${tritriintersect_SOURCE_DIR}>
  $<INSTALL_INTERFACE:tritriintersect>
  )
install(TARGETS tritriintersect)
install(DIRECTORY ${tritriintersect_SOURCE_DIR}
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/tritriintersect
  FILES_MATCHING PATTERN "*.h")

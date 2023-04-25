if(TARGET liblzf::liblzf)
  return()
endif()

set(liblzf_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/liblzf)

enable_language(C)
file(GLOB LIBLZF_SOURCE_FILES "${liblzf_SOURCE_DIR}/*.c")
add_library(liblzf ${LIBLZF_SOURCE_FILES})
add_library(liblzf::liblzf ALIAS liblzf)
target_include_directories(liblzf PUBLIC
  $<BUILD_INTERFACE:${liblzf_SOURCE_DIR}>
  $<INSTALL_INTERFACE:liblzf>)
set_target_properties(liblzf PROPERTIES LINKER_LANGUAGE C)
install(TARGETS liblzf)
#install(DIRECTORY ${liblzf_SOURCE_DIR}
#    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
#    FILES_MATCHING PATTERN "*.h")

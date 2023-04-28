configure_file("${PROJECT_SOURCE_DIR}/src/cupoch/cupoch_config.h.in"
    "${PROJECT_SOURCE_DIR}/src/cupoch/cupoch_config.h")

set(CUPOCH_MODULES)

add_subdirectory(camera)
add_subdirectory(collision)
add_subdirectory(geometry)
add_subdirectory(imageproc)
add_subdirectory(integration)
add_subdirectory(io)
add_subdirectory(kinematics)
add_subdirectory(kinfu)
add_subdirectory(knn)
add_subdirectory(odometry)
add_subdirectory(planning)
add_subdirectory(registration)
add_subdirectory(utility)
add_subdirectory(visualization)

# Installation
install(TARGETS ${CUPOCH_MODULES}
    EXPORT cupochTargets
    RUNTIME DESTINATION ${CUPOCH_INSTALL_BIN_DIR}
    LIBRARY DESTINATION ${CUPOCH_INSTALL_LIB_DIR}
    ARCHIVE DESTINATION ${CUPOCH_INSTALL_LIB_DIR}
)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING
    PATTERN "*.h"
    PATTERN "*.inl"
)

if(NOT BUILD_cupoch_visualization)
    return()
endif()
set(CUPOCH_MODULES ${CUPOCH_MODULES} cupoch_visualization PARENT_SCOPE)

file(GLOB SHADER_FILES "shader/glsl/*.glsl")

add_custom_command(
    OUTPUT ${PROJECT_SOURCE_DIR}/src/cupoch/visualization/shader/shader.h
    COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/scripts/encode_shader.py shader.h
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/src/cupoch/visualization/shader/
    DEPENDS ${SHADER_FILES}
)

foreach(file ${SHADER_FILES})
    add_custom_command(
        OUTPUT ${PROJECT_SOURCE_DIR}/src/cupoch/visualization/shader/shader.h
        COMMAND ${PYTHON_EXECUTABLE} ${PROJECT_SOURCE_DIR}/scripts/encode_shader.py shader.h ${file}
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/src/cupoch/visualization/shader/
        DEPENDS ${SHADER_FILES}
        APPEND
    )
endforeach(file)

add_custom_target(shader_file_target ALL
                  DEPENDS ${PROJECT_SOURCE_DIR}/src/cupoch/visualization/shader/shader.h)
set_target_properties(shader_file_target PROPERTIES FOLDER "custom")

find_package(GLEW REQUIRED CONFIG)
find_package(glfw3 REQUIRED CONFIG)
find_package(imgui REQUIRED CONFIG)

file(GLOB_RECURSE VISUALIZATION_CPP_SOURCE_FILES "*.cpp")
file(GLOB_RECURSE VISUALIZATION_CUDA_SOURCE_FILES "*.cu")
# create object library
add_library(cupoch_visualization ${VISUALIZATION_CUDA_SOURCE_FILES} ${VISUALIZATION_CPP_SOURCE_FILES})
add_dependencies(cupoch_visualization shader_file_target)
target_link_libraries(cupoch_visualization
    PUBLIC
        cupoch_camera
        cupoch_geometry
        cupoch_utility
        Eigen3::Eigen
        GLEW::GLEW
        glfw
    PRIVATE
        cupoch_io
        imgui::imgui
)

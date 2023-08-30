cmake_minimum_required(VERSION 3.18 FATAL_ERROR)

function(get_available_cuda_architectures CUDA_ARCHITECTURES)
    if (NOT CMAKE_CUDA_COMPILER_ID STREQUAL "NVIDIA")
        message(FATAL_ERROR "Unsupported CUDA compiler ${CMAKE_CUDA_COMPILER_ID}.")
    endif()
    if(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL "11.1")
        execute_process(COMMAND ${CMAKE_CUDA_COMPILER} --list-gpu-code
            RESULT_VARIABLE EXIT_CODE
            OUTPUT_VARIABLE OUTPUT_VAL
        )
        if(EXIT_CODE EQUAL 0)
            string(STRIP ${OUTPUT_VAL} OUTPUT_VAL)
            string(REPLACE "sm_" "" OUTPUT_VAL ${OUTPUT_VAL})
            string(REPLACE "\n" ";" ARCHITECTURES ${OUTPUT_VAL})
        else()
            message(FATAL_ERROR "Failed to run nvcc --list-gpu-code: ${EXIT_CODE}")
        endif()
    elseif(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL "11.0")
        set(ARCHITECTURES "35;37;50;52;53;60;61;62;70;72;75;80")
    elseif(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL "10.0")
        set(ARCHITECTURES "30;32;35;37;50;52;53;60;61;62;70;72;75")
    elseif(CMAKE_CUDA_COMPILER_VERSION VERSION_GREATER_EQUAL "9.1")
        set(ARCHITECTURES "30;32;35;37;50;52;53;60;61;62;70;72")
    else()
        set(ARCHITECTURES "30;32;35;37;50;52;53;60;61;62;70")
    endif()
    set(${CUDA_ARCHITECTURES} "${ARCHITECTURES}" PARENT_SCOPE)
endfunction()

# Sets the default value of CMAKE_CUDA_ARCHITECTURES effectively to "all":
# compile for all supported real (minor) architecture versions, and the highest virtual architecture version.
function(init_cmake_cuda_architectures)
    get_available_cuda_architectures(ALL_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES "")
    foreach(arch ${ALL_ARCHITECTURES})
        # Skip deprecated 3.x architectures
        if (arch GREATER_EQUAL 50)
            list(APPEND CMAKE_CUDA_ARCHITECTURES "${arch}-real")
        endif()
    endforeach()
    list(GET ALL_ARCHITECTURES -1 latest)
    list(APPEND CMAKE_CUDA_ARCHITECTURES "${latest}-virtual")
    set(CMAKE_CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    set(CMAKE_CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}" PARENT_SCOPE)
endfunction()
if(TARGET cupoch::flags)
    return()
endif()

if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    # Build with the default CUDA architectures set by nvcc if not specified
    set(CMAKE_CUDA_ARCHITECTURES "")
endif()

find_package(thrust REQUIRED CONFIG)
find_package(stdgpu REQUIRED CONFIG)
find_package(CUDAToolkit REQUIRED)
if(USE_RMM)
    find_package(rmm REQUIRED CONFIG)
endif()

add_library(cupoch_flags INTERFACE)
add_library(cupoch::flags ALIAS cupoch_flags)
target_compile_features(cupoch_flags INTERFACE
    cxx_std_17
    $<BUILD_INTERFACE:cuda_std_17>
)
target_compile_options(cupoch_flags INTERFACE
    "$<$<COMPILE_LANGUAGE:CUDA>:--expt-relaxed-constexpr>"
    "$<$<COMPILE_LANGUAGE:CUDA>:--expt-extended-lambda>"
    "$<$<COMPILE_LANGUAGE:CUDA>:--default-stream=per-thread>"
    "$<$<COMPILE_LANGUAGE:CUDA>:--use_fast_math>"
    "$<$<BOOL:UNIX>:$<$<COMPILE_LANGUAGE:CUDA>:--compiler-options=-fPIC>>"
    "$<$<BOOL:MSVC>:$<$<COMPILE_LANGUAGE:CUDA>:--no-host-device-move-forward>>"
    "$<$<COMPILE_LANGUAGE:CUDA>:-Xcudafe=--diag_suppress=integer_sign_change>"
    "$<$<COMPILE_LANGUAGE:CUDA>:-Xcudafe=--diag_suppress=partial_override>"
    "$<$<COMPILE_LANGUAGE:CUDA>:-Xcudafe=--diag_suppress=virtual_function_decl_hidden>"
)
target_link_libraries(cupoch_flags INTERFACE
    CUDA::cudart
    thrust::thrust
)
target_compile_definitions(cupoch_flags INTERFACE
    THRUST_IGNORE_CUB_VERSION_CHECK
    $<$<BOOL:USE_RMM>:USE_RMM>
)

if (TARGET cupoch::utility)
    target_link_libraries(cupoch::utility INTERFACE cupoch::flags)
endif()

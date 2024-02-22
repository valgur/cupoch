/**
 * Copyright (c) 2020 Neka-Nat
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 **/
#pragma once

#ifdef USE_RMM
#include <rmm/exec_policy.hpp>
#include <rmm/device_vector.hpp>
#include <rmm/device_uvector.hpp>

#include <rmm/mr/device/cuda_memory_resource.hpp>
#include <rmm/mr/device/managed_memory_resource.hpp>
#include <rmm/mr/device/pool_memory_resource.hpp>
#include <rmm/mr/device/thrust_allocator_adaptor.hpp>
#include <rmm/mr/device/owning_wrapper.hpp>
#else
#include <thrust/device_vector.h>
#endif
#include <thrust/host_vector.h>
#include <cupoch/utility/pinned_allocator.h>


#if defined(_WIN32)
struct float4_t {
    float x, y, z, w;
};

__host__ __device__ inline float4_t make_float4_t(float x,
                                                  float y,
                                                  float z,
                                                  float w) {
    float4_t f4 = {x, y, z, w};
    return f4;
}
#else
#include <cuda_runtime.h>
using float4_t = float4;

__host__ __device__ inline float4_t make_float4_t(float x,
                                                  float y,
                                                  float z,
                                                  float w) {
    return make_float4(x, y, z, w);
}
#endif

namespace cupoch {
namespace utility {

enum rmmAllocationMode_t {
    CudaDefaultAllocation = 0,
    PoolAllocation = 1,
    CudaManagedMemory = 2,
    CudaManagedMemoryPool = 3,
};

template <typename T>
using pinned_host_vector =
        thrust::host_vector<T, thrust::cuda::experimental::pinned_allocator<T>>;

#ifdef USE_RMM
template <typename T>
using device_vector = rmm::device_vector<T>;
template <typename T>
using device_uvector = rmm::device_uvector<T>;

inline decltype(auto) exec_policy(cudaStream_t stream = 0) {
    return rmm::exec_policy(stream);
}

void InitializeAllocator(
        rmmAllocationMode_t mode = CudaDefaultAllocation,
        size_t initial_pool_size = 0,
        const std::vector<int> &devices = {});

#else
template <typename T>
using device_vector = thrust::device_vector<T>;

inline decltype(auto) exec_policy(cudaStream_t stream = 0) {
    return thrust::cuda::par.on(stream);
}

inline void InitializeAllocator(
        rmmAllocationMode_t mode = CudaDefaultAllocation,
        size_t initial_pool_size = 0,
        const std::vector<int> &devices = {}) {}

#endif

}  // namespace utility
}  // namespace cupoch
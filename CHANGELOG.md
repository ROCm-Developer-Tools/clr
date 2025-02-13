# Change Log for HIP

Full documentation for HIP is available at [rocm.docs.amd.com](https://rocm.docs.amd.com/projects/HIP/en/latest/index.html)

## HIP 6.4 (For ROCm 6.4)

### Added

* New HIP APIs
    - `hipDeviceGetTexture1DLinearMaxWidth`  returns the maximum width of elements in a 1D linear texture, that can be allocated on the specified device.
    - `hipStreamBatchMemOp`  enqueues an array of batch memory operations in the stream, for stream synchronization.
    - `hipGraphAddBatchMemOpNode`  creates a batch memory operation node and adds it to a graph.
    - `hipGraphBatchMemOpNodeGetParams`  returns the pointer of parameters from the batch memory operation node.
    - `hipGraphBatchMemOpNodeSetParams`  sets parameters for the batch memory operation node.
    - `hipGraphExecBatchMemOpNodeSetParams`  sets the parameters for a batch memory operation node in the given executable graph.

### Resolved issues

* Out of memory error on Windows. When the user calls the API hipMalloc for device memory allocation specifying a size larger than the available device memory, the HIP runtime fixes the error in the API implementation, allocating the available device memory plus system memory (shared virtual memory). The fix is not available on Linux.

### Changed
  - roc-obj* tools are being deprecated, and will be removed in an upcoming release.
    - Perl package dependencies are now RECOMENDS or SUGGESTS.  Users will need to install these themselves.
    - Support for ROCm Object tooling has moved into llvm-objdump provided by package rocm-llvm.

## HIP 6.3.2 for ROCm 6.3.2

### Added

* Tracking of Heterogeneous System Architecture (HSA) handlers:
    - Adds an atomic counter to track the outstanding HSA handlers.
    - Waits on CPU for the callbacks if the number exceeds the defined value.
* Codes to capture Architected Queueing Language (AQL) packets for HIP graph memory copy node between host and device. HIP enqueues AQL packets during graph launch.
* Control to use system pool implementation in runtime commands handling. By default, it is disabled.
* A new path to avoid `WaitAny` calls in `AsyncEventsLoop`. The new path is selected by default.
* Runtime control on decrement counter only if event is popped. There is a new way to restore dead signals cleanup for the old path.
* A new logic in runtime to track the age of events from the kernel mode driver.

### Optimized

* HSA callback performance. The HIP runtime creates and submits commands in the queue and interacts with HSA through a callback function. HIP waits for the CPU status from HSA to optimize handling of events, profiling, commands, and HSA signals for higher performance.
* Runtime optimisation which combines all logic of `WaitAny` in a single processing loop and avoids extra memory allocations or reference counting. The runtime won't spin on the CPU if all events are busy.
* Multi-threaded dispatches for performance improvement.
* Command submissions and processing between CPU and GPU by introducing a way to limit the software batch size.
* Switch to `std::shared_mutex` in book/keep logic in streams from multiple threads simultaneously, for performance improvement in specific customer applications.
* `std::shared_mutex` is used in memory object mapping, for performance improvement.

### Resolved issues

* Race condition in multi-threaded producer/consumer scenario with `hipMallocFromPoolAsync`.
* Segmentation fault with `hipStreamLegacy` while using the API `hipStreamWaitEvent`.
* Usage of `hipStreamLegacy` in HIP event record.
* A soft hang in graph execution process from HIP user object. The fix handles the release of graph execution object properly considering synchronization on the device/stream. The user application now behaves the same with  hipUserObject  on both the AMD ROCm and NVIDIA CUDA platforms.


## HIP 6.3.1 for ROCm 6.3.1

### Added

* An activeQueues set that tracks only the queues that have a command submitted to them, which allows fast iteration in `waitActiveStreams`.

### Resolved issues

* A Deadlock in a specific customer application by preventing hipLaunchKernel latency degradation with number of idle streams.


## HIP 6.3 for ROCm 6.3

### Added

* New HIP APIs
    - `hipGraphExecGetFlags`  returns the flags on executable graph.
    - `hipGraphNodeSetParams`  updates parameters of a created node.
    - `hipGraphExecNodeSetParams`  updates parameters of a created node on executable graph.
    - `hipDrvGraphMemcpyNodeGetParams`  gets a memcpy node's parameters.
    - `hipDrvGraphMemcpyNodeSetParams`  sets a memcpy node's parameters.
    - `hipDrvGraphAddMemFreeNode`  creates a memory free node and adds it to a graph.
    - `hipDrvGraphExecMemcpyNodeSetParams`  sets the parameters for a memcpy node in the given graphExec.
    - `hipDrvGraphExecMemsetNodeSetParams`  sets the parameters for a memset node in the given graphExec.

### Changed

* Un-deprecated HIP APIs
    - `hipHostAlloc`
    - `hipFreeHost`

### Optimized

* Disabled CPU wait in device synchronize to avoid idle time in applications such as Hugging Face models and PyTorch.
* Optimized multi-threaded dispatches to improve performance.
* Limited the software batch size to control the number of command submissions for runtime to handle efficiently.
* Optimizes HSA callback performance when a large number of events are recorded by multiple threads and submitted to multiple GPUs.

### Resolved issues

* Soft hang in runtime wait event when run TensorFlow.
* Memory leak in the API `hipGraphInstantiate` when kernel is launched using `hipExtLaunchKernelGGL` with event.
* Memory leak when the API `hipGraphAddMemAllocNode` is called.
* The `_sync()` version of crosslane builtins such as `shfl_sync()`,
  `__all_sync()` and `__any_sync()`, continue to be hidden behind the
  preprocessor macro `HIP_ENABLE_WARP_SYNC_BUILTINS`, and will be enabled
  unconditionally in the next ROCm release.


## HIP 6.2.41134 for ROCm 6.2.1

### Resolved issues

* Soft hang when use AMD_SERIALIZE_KERNEL.
* Memory leak in hipIpcCloseMemHandle.


## HIP 6.2 (For ROCm 6.2)

### Added
- Introduced the `_sync()` version of crosslane builtins such as `shfl_sync()`, `__all_sync()`
  and `__any_sync()`. These take a 64-bit integer as an explicit mask argument.
  - In HIP 6.2, these are hidden behind the preprocessor macro
    `HIP_ENABLE_WARP_SYNC_BUILTINS`, and will be enabled unconditionally in HIP 6.3.
- Added new HIP APIs
    - `hipGetProcAddress` returns the pointer to driver function, corresponding to the defined driver function symbol.
    - `hipGetFuncBySymbol` returns the pointer to device entry function that matches entry function symbolPtr.
    - `hipStreamBeginCaptureToGraph` begins graph capture on a stream to an existing graph.
    - `hipGraphInstantiateWithParams`  creates an executable graph from a graph.
    - `hipMemcpyAtoA`  copies from one 1D array to another.
    - `hipMemcpyDtoA`  copies from device memory to a 1D array.
    - `hipMemcpyAtoD`  copies from one 1D array to device memory.
    - `hipMemcpyAtoHAsync`  copies from one 1D array to host memory.
    - `hipMemcpyHtoAAsync`  copies from host memory to a 1D array.
    - `hipMemcpy2DArrayToArray`  copies data between host and device.

- Added a new flag `integrated` support in device property

    The `integrated` flag is added in the struct `hipDeviceProp_t`.
    On the integrated `APU` system, the runtime driver detects and sets this flag to `1`, in which case the API `hipDeviceGetAttribute` returns enum `hipDeviceAttribute_t` for hipDeviceAttributeIntegrated as value `1`, for integrated GPU device.

    The enum value `hipDeviceAttributeIntegrated` corresponds to `cudaDevAttrIntegrated` on CUDA platform.
- Added initial support for 8-bit floating point datatype in `amd_hip_fp8.h`. These are accessible via `#include <hip/hip_fp8.h>`
- Add UUID support for environment variable `HIP_VISIBLE_DEVICES`.

### Resolved issues
- Stream capture support in HIP graph.
Prohibited and unhandled operations are fixed during stream capture in HIP runtime.
- Fix undefined symbol error for hipTexRefGetArray & hipTexRefGetBorderColor.

## HIP 6.1 (For ROCm 6.1)

### Added
- New environment variable HIP_LAUNCH_BLOCKING
It is used for serialization on kernel execution.
The default value is 0 (disable), kernel will execute normally as defined in the queue. When this environment variable is set as 1 (enable), HIP runtime will serialize kernel enqueue, behaves the same as AMD_SERIALIZE_KERNEL.
- Added HIPRTC support for hip headers driver_types, math_functions, library_types, math_functions, hip_math_constants, channel_descriptor, device_functions, hip_complex, surface_types, texture_types.

### Changed
- HIPRTC now assumes WGP mode for gfx10+. CU mode can be enabled by passing `-mcumode` to the compile options from `hiprtcCompileProgram`.

### Resolved issues
- HIP complex vector type multiplication and division operations.
On AMD platform, some duplicated complex operators are removed to avoid compilation failures.
In HIP, hipFloatComplex and hipDoubleComplex are defined as complex data types,
typedef float2 hipFloatComplex;
typedef double2 hipDoubleComplex;
Any application uses complex multiplication and division operations, need to replace '*' and '/' operators with the following,
    - hipCmulf() and hipCdivf() for hipFloatComplex
    - hipCmul() and hipCdiv() for hipDoubleComplex

    Note: These complex operations are equivalent to corresponding types/functions on NVIDIA platform.

## HIP 6.0 (For ROCm 6.0)

### Added
- Addition of hipExtGetLastError
  - AMD backend specific API, to return error code from last HIP API called from the active host thread

- New fields for external resource interoperability,
  - Structs
    - hipExternalMemoryHandleDesc_st
    - hipExternalMemoryBufferDesc_st
    - hipExternalSemaphoreHandleDesc_st
    - hipExternalSemaphoreSignalParams_st
    - hipExternalSemaphoreWaitParams_st
  - Enumerations
    - hipExternalMemoryHandleType_enum
    - hipExternalSemaphoreHandleType_enum
    - hipExternalMemoryHandleType_enum

- New members are added in HIP struct hipDeviceProp_t, for new feature capabilities including,
  - Texture
     - int maxTexture1DMipmap;
     - int maxTexture2DMipmap[2];
     - int maxTexture2DLinear[3];
     - int maxTexture2DGather[2];
     - int maxTexture3DAlt[3];
     - int maxTextureCubemap;
     - int maxTexture1DLayered[2];
     - int maxTexture2DLayered[3];
     - int maxTextureCubemapLayered[2];
  - Surface
     - int maxSurface1D;
     - int maxSurface2D[2];
     - int maxSurface3D[3];
     - int maxSurface1DLayered[2];
     - int maxSurface2DLayered[3];
     - int maxSurfaceCubemap;
     - int maxSurfaceCubemapLayered[2];
  - Device
     - hipUUID uuid;
     - char luid[8];
       -- this is 8-byte unique identifier. Only valid on windows
       -- LUID (Locally Unique Identifier) is supported for interoperability between devices.
     - unsigned int luidDeviceNodeMask; \

     Note: HIP supports LUID only on Windows OS.
- Added `amd_hip_bf16.h` which adds `bfloat16` type. These definitions are accessible via `#include <hip/hip_bf16.h>`
This header exists alongside the older bfloat16 header in`amd_hip_bfloat16.h` which is included via `hip/hip_bfloat16.h`. Users are recommended to use `<hip/hip_bf16.h>` instead of `<hip/hip_bfloat16.h>`.

### Changed
- Some OpenGL Interop HIP APIs are moved from the hip_runtime_api header to a new header file hip_gl_interop.h for the AMD platform, as following,
    - hipGLGetDevices
    - hipGraphicsGLRegisterBuffer
    - hipGraphicsGLRegisterImage
- With ROCm 6.0, the HIP version is 6.0. As the HIP runtime binary suffix is updated in every major ROCm release, in ROCm 6.0, the new filename is libamdhip64.so.6. Furthermore, in ROCm 6.0 release, the libamdhip64.so.5 binary from ROCm 5.7 is made available to maintain binary backward compatibility with ROCm 5.x.

### Changed Impacting Backward Compatibility
- Data types for members in HIP_MEMCPY3D structure are changed from "unsigned int" to "size_t".
- The value of the flag hipIpcMemLazyEnablePeerAccess is changed to “0x01”, which was previously defined as “0”.
- Some device property attributes are not currently support in HIP runtime, in order to maintain consistency, the following related enumeration names are changed in hipDeviceAttribute_t
    - hipDeviceAttributeName is changed to hipDeviceAttributeUnused1
    - hipDeviceAttributeUuid is changed to hipDeviceAttributeUnused2
    - hipDeviceAttributeArch is changed to hipDeviceAttributeUnused3
    - hipDeviceAttributeGcnArch is changed to hipDeviceAttributeUnused4
    - hipDeviceAttributeGcnArchName is changed to hipDeviceAttributeUnused5
- HIP struct hipArray is removed from driver type header to be complying with cuda
- hipArray_t replaces hipArray*, as the pointer to array.
    - This allows hipMemcpyAtoH and hipMemcpyHtoA to have the correct array type which is equivalent to coresponding CUDA driver APIs.

### Removed
- Deprecated Heterogeneous Compute (HCC) symbols and flags are removed from the HIP source code, including,
    - Build options on obsolete HCC_OPTIONS was removed from cmake.
    - Micro definitions are removed.
      HIP_INCLUDE_HIP_HCC_DETAIL_DRIVER_TYPES_H
      HIP_INCLUDE_HIP_HCC_DETAIL_HOST_DEFINES_H
    - Compilation flags for the platform definitions,
      AMD platform,
      __HIP_PLATFORM_HCC__
      __HCC__
      __HIP_ROCclr__
      NVIDIA platform,
      __HIP_PLATFORM_NVCC__
- File directories in the clr repository are removed,
  https://github.com/ROCm/clr/blob/develop/hipamd/include/hip/hcc_detail
  https://github.com/ROCm/clr/blob/develop/hipamd/include/hip/nvcc_detail
- Deprecated gcnArch is removed from hip device struct hipDeviceProp_t.
- Deprecated "enum hipMemoryType memoryType;" is removed from HIP struct hipPointerAttribute_t union.
- Deprecated HIT based tests are removed from HIP project
- Catch tests are available [hip-tests] (https://github.com/ROCm/hip-tests) project

### Resolved issues
- Kernel launch maximum dimension validation is added specifically on gridY and gridZ in the HIP API hipModule-LaunchKernel. As a result,when hipGetDeviceAttribute is called for the value of hipDeviceAttributeMaxGrid-Dim, the behavior on the AMD platform is equivalent to NVIDIA.
- The HIP stream synchronisation behaviour is changed in internal stream functions, in which a flag "wait" is added and set when the current stream is null pointer while executing stream synchronisation on other explicitly created streams. This change avoids blocking of execution on null/default stream.
The change won't affect usage of applications, and makes them behave the same on the AMD platform as NVIDIA.
- Error handling behavior on unsupported GPU is fixed, HIP runtime will log out error message, instead of creating signal abortion error which is invisible to developers but continued kernel execution process. This is for the case when developers compile any application via hipcc, setting the option --offload-arch with GPU ID which is different from the one on the system.

### Known Issues
- Dynamically loaded HIP runtime library references incorrect version of hipDeviceGetProperties and hipChooseDevice APIs

When an application dynamically loads the HIP runtime library from ROCm 6.0 and attempts to get the hipDeviceGetProperties and/or hipChooseDevice entry-points using dlsym, the application gets the older version (ROCm 5.7) of those entry-points.

As a workaround, while compiling with ROCm 6.0, use the string "hipDeviceGetPropertiesR0600", and "hipChooseDeviceR0600" respectively for hipDeviceGetProperties and hipChooseDevice APIs.

## HIP 5.7.1 (For ROCm 5.7.1)

### Resolved issues
- hipPointerGetAttributes API returns the correct HIP memory type as hipMemoryTypeManaged for managed memory.

## HIP 5.7 (For ROCm 5.7)

### Added
- Added meta_group_size/rank for getting the number of tiles and rank of a tile in the partition
- Added new APIs supporting Windows only, under development on Linux

    - hipMallocMipmappedArray for allocating a mipmapped array on the device

    - hipFreeMipmappedArray for freeing a mipmapped array on the device

    - hipGetMipmappedArrayLevel for getting a mipmap level of a HIP mipmapped array

    - hipMipmappedArrayCreate for creating a mipmapped array

    - hipMipmappedArrayDestroy for destroy a mipmapped array

    - hipMipmappedArrayGetLevel for getting a mipmapped array on a mipmapped level

### Known Issues
- HIP memory type enum values currently don't support equivalent value to cudaMemoryTypeUnregistered, due to HIP functionality backward compatibility.
- HIP API hipPointerGetAttributes could return invalid value in case the input memory pointer was not allocated through any HIP API on device or host.

### Upcoming changes
- Removal of gcnarch from hipDeviceProp_t structure
- Addition of new fields in hipDeviceProp_t structure
  - maxTexture1D
  - maxTexture2D
  - maxTexture1DLayered
  - maxTexture2DLayered
  - sharedMemPerMultiprocessor
  - deviceOverlap
  - asyncEngineCount
  - surfaceAlignment
  - unifiedAddressing
  - computePreemptionSupported
  - hostRegisterSupported
  - uuid
- Removal of deprecated code
  -hip-hcc codes from hip code tree
- Correct hipArray usage in HIP APIs such as hipMemcpyAtoH and hipMemcpyHtoA
- HIPMEMCPY_3D fields correction to avoid truncation of "size_t" to "unsigned int" inside hipMemcpy3D()
- Renaming of 'memoryType' in hipPointerAttribute_t structure to 'type'
- Correct hipGetLastError to return the last error instead of last API call's return code
- Update hipExternalSemaphoreHandleDesc to add "unsigned int reserved[16]"
- Correct handling of flag values in hipIpcOpenMemHandle for hipIpcMemLazyEnablePeerAccess
- Remove hiparray* and make it opaque with hipArray_t

## HIP 5.6.1 (For ROCm 5.6.1)

### Resolved issues
- Enabled xnack+ check in HIP catch2 tests hang while tests execution
- Memory leak when code object files are loaded/unloaded via hipModuleLoad/hipModuleUnload APIs
- Resolved an issue of crash while using hipGraphAddMemFreeNode

## HIP 5.6 (For ROCm 5.6)

### Added
- Added hipRTC support for amd_hip_fp16
- Added hipStreamGetDevice implementation to get the device assocaited with the stream
- Added HIP_AD_FORMAT_SIGNED_INT16 in hipArray formats
- hipArrayGetInfo for getting information about the specified array
- hipArrayGetDescriptor for getting 1D or 2D array descriptor
- hipArray3DGetDescriptor to get 3D array descriptor

### Changed
- hipMallocAsync to return success for zero size allocation to match hipMalloc
- Separation of hipcc perl binaries from HIP project to hipcc project. hip-devel package depends on newly added hipcc package
- Consolidation of hipamd, ROCclr, and OpenCL repositories into a single repository called clr. Instructions are updated to build HIP from sources in the HIP Installation guide
- Removed hipBusBandwidth and hipCommander samples from hip-tests

### Optimized
- Consolidation of hipamd, rocclr and OpenCL projects in clr
- Optimized lock for graph global capture mode

### Resolved issues
- Fixed regression in hipMemCpyParam3D when offset is applied

### Known Issues
- Limited testing on xnack+ configuration
  - Multiple HIP tests failures (gpuvm fault or hangs)
- hipSetDevice and hipSetDeviceFlags APIs return hipErrorInvalidDevice instead of hipErrorNoDevice, on a system without GPU
- Known memory leak when code object files are loaded/unloaded via hipModuleLoad/hipModuleUnload APIs. Issue will be fixed in future release

### Upcoming changes
- Removal of gcnarch from hipDeviceProp_t structure
- Addition of new fields in hipDeviceProp_t structure
  - maxTexture1D
  - maxTexture2D
  - maxTexture1DLayered
  - maxTexture2DLayered
  - sharedMemPerMultiprocessor
  - deviceOverlap
  - asyncEngineCount
  - surfaceAlignment
  - unifiedAddressing
  - computePreemptionSupported
  - hostRegisterSupported
  - uuid
- Removal of deprecated code
  -hip-hcc codes from HIP code tree
- Correct hipArray usage in HIP APIs such as hipMemcpyAtoH and hipMemcpyHtoA
- HIPMEMCPY_3D fields correction to avoid truncation of "size_t" to "unsigned int" inside hipMemcpy3D()
- Renaming of 'memoryType' in hipPointerAttribute_t structure to 'type'
- Correct hipGetLastError to return the last error instead of last API call's return code
- Update hipExternalSemaphoreHandleDesc to add "unsigned int reserved[16]"
- Correct handling of flag values in hipIpcOpenMemHandle for hipIpcMemLazyEnablePeerAccess
- Remove hiparray* and make it opaque with hipArray_t

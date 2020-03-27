# Generated by CMake 3.5.1

if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}" LESS 2.5)
   message(FATAL_ERROR "CMake >= 2.6.0 required")
endif()
cmake_policy(PUSH)
cmake_policy(VERSION 2.6)
#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Protect against multiple inclusion, which would fail when already imported targets are added once more.
set(_targetsDefined)
set(_targetsNotDefined)
set(_expectedTargets)
foreach(_expectedTarget hip::hip_hcc_static hip::hip_hcc hip::host hip::device)
  list(APPEND _expectedTargets ${_expectedTarget})
  if(NOT TARGET ${_expectedTarget})
    list(APPEND _targetsNotDefined ${_expectedTarget})
  endif()
  if(TARGET ${_expectedTarget})
    list(APPEND _targetsDefined ${_expectedTarget})
  endif()
endforeach()
if("${_targetsDefined}" STREQUAL "${_expectedTargets}")
  set(CMAKE_IMPORT_FILE_VERSION)
  cmake_policy(POP)
  return()
endif()
if(NOT "${_targetsDefined}" STREQUAL "")
  message(FATAL_ERROR "Some (but not all) targets in this export set were already defined.\nTargets Defined: ${_targetsDefined}\nTargets not yet defined: ${_targetsNotDefined}\n")
endif()
unset(_targetsDefined)
unset(_targetsNotDefined)
unset(_expectedTargets)

#If HIP isnot installed under ROCm, need this to find HSA assuming HSA is under ROCm
if( DEFINED ENV{ROCM_PATH} )
     set(ROCM_PATH "$ENV{ROCM_PATH}")
endif()

#get_filename_component cannot resolve the symlinks if called from /opt/rocm/lib/hip
#and do three level up again
get_filename_component(_DIR "${CMAKE_CURRENT_LIST_DIR}" REALPATH)
get_filename_component(_IMPORT_PREFIX "${_DIR}/../../../" REALPATH)

# Create imported target hip::hip_hcc_static
add_library(hip::hip_hcc_static STATIC IMPORTED)

#if HSA is not under ROCm then provide CMAKE_PREFIX_PATH=<HSA_PATH>
find_path(HSA_HEADER hsa/hsa.h
  PATHS
    "${ROCM_PATH}/include"
    #Assuming HIP is installed under ROCm
    "${_IMPORT_PREFIX}/../include"
    /opt/rocm/include
)

if (HSA_HEADER-NOTFOUND)
  message (FATAL_ERROR "HSA header not found! ROCM_PATH environment not set")
endif()

set_target_properties(hip::hip_hcc_static PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include;${HSA_HEADER}"
  INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include;${HSA_HEADER}"
)

# Create imported target hip::hip_hcc
add_library(hip::hip_hcc SHARED IMPORTED)

set_target_properties(hip::hip_hcc PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include;${HSA_HEADER}"
  INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include;${HSA_HEADER}"
)

# Create imported target hip::host
add_library(hip::host INTERFACE IMPORTED)

set_target_properties(hip::host PROPERTIES
  INTERFACE_LINK_LIBRARIES "hip::hip_hcc"
)

# Create imported target hip::device
add_library(hip::device INTERFACE IMPORTED)

if(HIP_COMPILER STREQUAL "hcc")
set_target_properties(hip::device PROPERTIES
  INTERFACE_LINK_LIBRARIES "hip::host;hcc::hccrt;hcc::hc_am"
  INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/../include"
  INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/../include"
)
else()
set_target_properties(hip::device PROPERTIES
  INTERFACE_LINK_LIBRARIES "hip::host"
)
endif()

if(CMAKE_VERSION VERSION_LESS 3.0.0)
  message(FATAL_ERROR "This file relies on consumers using CMake 3.0.0 or greater.")
endif()

# Load information for each installed configuration.
get_filename_component(_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
file(GLOB CONFIG_FILES "${_DIR}/hip-targets-*.cmake")
foreach(f ${CONFIG_FILES})
  include(${f})
endforeach()

# Cleanup temporary variables.
set(_IMPORT_PREFIX)

# Loop over all imported files and verify that they actually exist
foreach(target ${_IMPORT_CHECK_TARGETS} )
  foreach(file ${_IMPORT_CHECK_FILES_FOR_${target}} )
    if(NOT EXISTS "${file}" )
      message(FATAL_ERROR "The imported target \"${target}\" references the file
   \"${file}\"
but this file does not exist.  Possible reasons include:
* The file was deleted, renamed, or moved to another location.
* An install or uninstall procedure did not complete successfully.
* The installation package was faulty and contained
   \"${CMAKE_CURRENT_LIST_FILE}\"
but not all the files it references.
")
    endif()
  endforeach()
  unset(_IMPORT_CHECK_FILES_FOR_${target})
endforeach()
unset(_IMPORT_CHECK_TARGETS)

# This file does not depend on other imported targets which have
# been exported from the same project but in a separate export set.

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
cmake_policy(POP)

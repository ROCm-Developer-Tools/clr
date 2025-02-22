# Copyright (c) 2022 - 2023 Advanced Micro Devices, Inc. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

cmake_minimum_required(VERSION 3.16.3)
project(clr)

##########
# Defaults
##########
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_compile_options("/wd4267" "/wd4244" "/wd4996")
    string(REPLACE "/GR" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
    string(REPLACE "/W3" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
endif()
option(CLR_BUILD_HIP "Build HIP" OFF)
option(CLR_BUILD_OCL "Build OCL" OFF)

# Set default build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
endif()

#############
# Build steps
#############
if(CLR_BUILD_HIP)
  if (UNIX)
    set(HIPCC_EXECUTABLE "hipcc")
    set(HIPCONFIG_EXECUTABLE "hipconfig")
  else()
    set(HIPCC_EXECUTABLE "hipcc.exe")
    set(HIPCONFIG_EXECUTABLE "hipconfig.exe")
  endif()

    # Set default HIPCC_BIN_DIR to /opt/rocm/bin
    if(NOT DEFINED HIPCC_BIN_DIR AND UNIX)
        set(HIPCC_BIN_DIR "/opt/rocm/bin" CACHE STRING "Default hipcc directory on linux.")
    endif()
    message(STATUS "HIPCC Binary Directory: ${HIPCC_BIN_DIR}")

    if(NOT EXISTS ${HIPCC_BIN_DIR}/${HIPCONFIG_EXECUTABLE})
        message(FATAL_ERROR "Please pass hipcc/build or hipcc/bin using -DHIPCC_BIN_DIR.")
    endif()

    message(STATUS "HIP Common Directory: ${HIP_COMMON_DIR}")
    if(NOT DEFINED HIP_COMMON_DIR)
        message(FATAL_ERROR "Please pass HIP using -DHIP_COMMON_DIR. HIP_COMMON_DIR is incorrect")
    endif()
    # Determine HIP_PLATFORM
    if(NOT DEFINED HIP_PLATFORM)
        if(NOT DEFINED ENV{HIP_PLATFORM})
            execute_process(COMMAND ${HIPCC_BIN_DIR}/${HIPCONFIG_EXECUTABLE} --platform
                OUTPUT_VARIABLE HIP_PLATFORM
                OUTPUT_STRIP_TRAILING_WHITESPACE)
        else()
            set(HIP_PLATFORM $ENV{HIP_PLATFORM} CACHE STRING "HIP Platform")
        endif()
    endif()
endif()
if(CLR_BUILD_HIP)
    option(BUILD_SHARED_LIBS "Build the shared library" ON)
    if (NOT BUILD_SHARED_LIBS)
        add_compile_definitions(BUILD_STATIC_LIBS)
    endif()
endif()
if((CLR_BUILD_HIP AND HIP_PLATFORM STREQUAL "amd") OR CLR_BUILD_OCL)
    add_subdirectory(rocclr)
elseif(HIP_PLATFORM STREQUAL "amd")
    message(FATAL_ERROR "Please enable building of one or more of the below runtimes:\n- HIP (-DCLR_BUILD_HIP=ON)\n- OpenCL (-DCLR_BUILD_OCL-ON)")
endif()
if(CLR_BUILD_HIP)
    add_subdirectory(hipamd)
endif()
if(CLR_BUILD_OCL)
    add_subdirectory(opencl)
endif()

#############################
# Code formatting
#############################
# Target: clangformat
find_program(CLANGFORMAT_EXE clang-format PATHS "/opt/rocm/lib/llvm/bin")
if(CLANGFORMAT_EXE)
    file(GLOB_RECURSE FORMAT_SOURCE_FILE_LIST *.cpp *.hpp *.hh *.h *.cc *.c)
    add_custom_target(clangformat COMMAND ${CLANGFORMAT_EXE} -style=file -i ${FORMAT_SOURCE_FILE_LIST}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()

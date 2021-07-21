cmake_minimum_required(VERSION 3.1)
project(Diospyros)

# Build the Rust library.
include(ExternalProject)
ExternalProject_Add(
    DiospyrosLib
    DOWNLOAD_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND cargo build COMMAND cargo build --release
    BINARY_DIR "${CMAKE_SOURCE_DIR}"
    INSTALL_COMMAND ""
    LOG_BUILD ON)

# support C++14 features used by LLVM 10.0.0
set(CMAKE_CXX_STANDARD 14)

find_package(LLVM REQUIRED CONFIG)
add_definitions(${LLVM_DEFINITIONS})
include_directories(${LLVM_INCLUDE_DIRS})
link_directories(${LLVM_LIBRARY_DIRS})

# Build the LLVM pass itself.
add_subdirectory(Diospyros)

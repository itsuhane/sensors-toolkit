cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
project(sensors-toolkit)

include(CMakeDependentOption)
include(SuperBuildDepends)
superbuild_option(cpp17)
superbuild_option(modern-cpp)

cmake_dependent_option(SENSORS_BUILD_PC_APP "..." ON "NOT IOS" OFF)
cmake_dependent_option(SENSORS_BUILD_IOS_APP "..." ON "IOS" OFF)

add_subdirectory(libsensors)

if(SENSORS_BUILD_PC_APP)
  add_subdirectory(sensors-pc)
endif()

if(SENSORS_BUILD_IOS_APP)
  add_subdirectory(sensors-ios)
endif()

cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
project(sensors-pc LANGUAGES CXX)

include(SuperBuildDepends)
superbuild_extern(opencv)

add_executable(sensors-decode
  ${CMAKE_CURRENT_SOURCE_DIR}/sensors-decode/main.cpp
)

target_link_libraries(sensors-decode
  sensors
  options::modern-cpp
)

add_executable(sensors-preview
  ${CMAKE_CURRENT_SOURCE_DIR}/sensors-preview/main.cpp
)

target_link_libraries(sensors-preview
  sensors
  options::modern-cpp
  depends::opencv
)

cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
project(libsensors LANGUAGES CXX)

add_library(sensors
    ${CMAKE_CURRENT_SOURCE_DIR}/include/libsensors.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/libsensors.cpp
)

target_compile_features(sensors
    PUBLIC
        cxx_std_17
)

target_include_directories(sensors
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/
)

if(NOT SENSORS_BUILD_IOS)
    target_link_libraries(
        sensors
        PUBLIC
            ffmpeg-dep
    )
endif()

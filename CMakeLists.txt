cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
project(sensors-toolkit)

include(CMakeDependentOption)

cmake_dependent_option(SENSORS_BUILD_LIB "..." ON "NOT IOS" OFF)
cmake_dependent_option(SENSORS_BUILD_PC "..." ON "NOT IOS" OFF)
cmake_dependent_option(SENSORS_BUILD_IOS "..." ON "IOS" OFF)

if(SENSORS_BUILD_PC)
    find_package(OpenCV REQUIRED)
    find_package(FFmpeg COMPONENTS AVCODEC AVUTIL REQUIRED)

    add_library(opencv-dep INTERFACE IMPORTED GLOBAL)
    target_include_directories(opencv-dep INTERFACE ${OpenCV_INCLUDE_DIR})
    target_link_libraries(opencv-dep INTERFACE ${OpenCV_LIBS})

    add_library(ffmpeg-dep INTERFACE IMPORTED)
    target_include_directories(ffmpeg-dep INTERFACE ${FFMPEG_INCLUDE_DIRS})
    target_link_libraries(ffmpeg-dep INTERFACE ${FFMPEG_LIBRARIES})
endif()

if(SENSORS_BUILD_LIB)
    add_subdirectory(libsensors)
endif()
if(SENSORS_BUILD_PC)
    add_subdirectory(sensors-pc)
endif()
if(SENSORS_BUILD_IOS)
    add_subdirectory(sensors-ios)
endif()

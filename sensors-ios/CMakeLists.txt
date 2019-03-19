cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules")
project(sensors-ios VERSION 0.0.1 LANGUAGES CXX Swift)

set(CODE_SIGN_IDENTITY "iPhone Developer")      # /usr/bin/env xcrun security find-identity -v -p codesigning
set(DEVELOPMENT_TEAM "${IOS_DEVELOPMENT_TEAM}") # XCode: Build Settings > Signing > Development Team

set(TARGETED_DEVICE_FAMILY "1") # 1: iphone; 2: ipad; 1,2: both

set(EXECUTABLE_NAME sensors-recorder)
set(BUNDLE_NAME "sensors-recorder")
set(BUNDLE_IDENTIFIER "${APP_IDENTIFIER_PREFIX}.recorder")
set(BUNDLE_VERSION ${PROJECT_VERSION})
set(LAUNCH_STORYBOARD LaunchScreen)
set(MAIN_STORYBOARD Main)
set(SWIFT_OBJC_BRIDGING_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/src/Sensors-Bridging-Header.h)

set(INFO_PLIST_TEMPLATE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Info.plist.in)

set(SENSORS_IOS_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/NetworkOutputServerImpl.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/NetworkOutputServerImpl.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/NetworkOutputServer.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/NetworkOutputServer.mm
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AppDelegate.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AppUtility.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Camera.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Encoder.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/FileOutput.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Location.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Motion.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/NetworkOutput.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Pipeline.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/VideoToolbox+extensions.swift
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ViewController.swift
)

set(SENSORS_IOS_ASSETS
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/Media.xcassets
)

set(SENSORS_IOS_STORYBOARDS
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/${LAUNCH_STORYBOARD}.storyboard
    ${CMAKE_CURRENT_SOURCE_DIR}/resources/${MAIN_STORYBOARD}.storyboard
)

set(SENSORS_IOS_RESOURCES
    ${SENSORS_IOS_ASSETS}
    ${SENSORS_IOS_STORYBOARDS}
)

add_executable(${EXECUTABLE_NAME}
    MACOSX_BUNDLE
    ${SWIFT_OBJC_BRIDGING_HEADER}
    ${SENSORS_IOS_SOURCES}
    ${SENSORS_IOS_ASSETS}
    ${SENSORS_IOS_STORYBOARDS}
)

target_compile_features(${EXECUTABLE_NAME}
    PRIVATE
        cxx_std_17
)

set_target_properties(${EXECUTABLE_NAME} PROPERTIES
    MACOSX_BUNDLE_INFO_PLIST ${INFO_PLIST_TEMPLATE}
    RESOURCE "${SENSORS_IOS_RESOURCES}"
)

set_xcode_property(${EXECUTABLE_NAME} CODE_SIGN_IDENTITY ${CODE_SIGN_IDENTITY} "All")
set_xcode_property(${EXECUTABLE_NAME} DEVELOPMENT_TEAM ${DEVELOPMENT_TEAM} "All")
set_xcode_property(${EXECUTABLE_NAME} TARGETED_DEVICE_FAMILY ${TARGETED_DEVICE_FAMILY} "All")
set_xcode_property(${EXECUTABLE_NAME} IPHONEOS_DEPLOYMENT_TARGET ${IOS_DEPLOYMENT_TARGET} "All")
set_xcode_property(${EXECUTABLE_NAME} SWIFT_OBJC_BRIDGING_HEADER ${SWIFT_OBJC_BRIDGING_HEADER} "All")
set_xcode_property(${EXECUTABLE_NAME} SWIFT_VERSION "4.2" "All")
set_xcode_property(${EXECUTABLE_NAME} DEBUG_INFORMATION_FORMAT "dwarf-with-dsym" "All")
set_xcode_property(${EXECUTABLE_NAME} LD_RUNPATH_SEARCH_PATHS "@executable_path/Frameworks" "All")
if(ENABLE_BITCODE)
    set_xcode_property(${EXECUTABLE_NAME} ENABLE_BITCODE "YES" "All")
else()
    set_xcode_property(${EXECUTABLE_NAME} ENABLE_BITCODE "NO" "All")
endif()
if(ENABLE_ARC)
    set_xcode_property(${EXECUTABLE_NAME} CLANG_ENABLE_OBJC_ARC "YES" "All")
else()
    set_xcode_property(${EXECUTABLE_NAME} CLANG_ENABLE_OBJC_ARC "NO" "All")
endif()

cmake_minimum_required(VERSION 2.8.12)

project(text-pango)

# Standalone build
if(NOT OBS_OUTPUT_DIR)
    set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
    include(ObsHelpers)

    set(CMAKE_C_STANDARD 11)

    find_path(OBS_INCLUDE_DIRS
        obs-module.h
        HINTS $ENV{OBS_DIR}
        PATH_SUFFIXES 
            libobs)
    find_library(OBS_LIBRARIES
        NAMES obs libobs
        HINTS $ENV{OBS_DIR}
        PATH_SUFFIXES
            build_release/libobs
            libobs)
# Build as submodule of obs-studio
else()
    set(OBS_INCLUDE_DIRS
        ../../libobs)
    set(OBS_LIBRARIES
        libobs)
endif()

find_package(pango REQUIRED)
find_package(cairo REQUIRED)
find_package(pangocairo REQUIRED)
find_package(pangowin32 REQUIRED)
find_package(fontconfig REQUIRED)

include_directories(
    ${OBS_INCLUDE_DIRS}
	${PANGO_INCLUDE_DIRS}
	${CAIRO_INCLUDE_DIRS}
	${PANGOCAIRO_INCLUDE_DIRS})
link_directories("D:/projects/text-rendering/build_release/install/lib")

set(text-pango_SOURCES
	text-pango.c
	text-pango.h)

add_library(text-pango MODULE
	${text-pango_SOURCES})
target_link_libraries(text-pango
	${OBS_LIBRARIES}
    ${CAIRO_LIBRARIES}
    ${PANGO_LIBRARIES}
    intl
    mini-fribidi
    ${PANGOWIN32_LIBRARIES}
    ${PANGOCAIRO_LIBRARIES}
    pixman-1_static
    zlib
    freetype
    harfbuzz
    libpng16
    expat
    ${FONTCONFIG_LIBRARIES}
    usp10)
target_compile_definitions(text-pango PRIVATE ${CAIRO_C_FLAGS})
# install_obs_plugin_with_data(text-pango data)


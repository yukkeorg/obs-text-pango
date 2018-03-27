cmake_minimum_required(VERSION 2.8.12)

project(text-pango)

# Standalone build
if(NOT OBS_OUTPUT_DIR)
	set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/")
	include(ObsHelpers)

	set(CMAKE_C_STANDARD 11)
	set(STANDALONE_PLUGIN TRUE)

	find_path(OBS_INCLUDE_DIRS
		obs-module.h
		HINTS $ENV{OBS_DIR} ${OBS_DIR}
		PATH_SUFFIXES 
			libobs)
	find_library(OBS_LIBRARIES
		NAMES obs libobs
		HINTS $ENV{OBS_DIR} ${OBS_DIR}
		PATH_SUFFIXES
			build_rel/libobs
			libobs)
# Build as submodule of obs-studio
else()
	set(OBS_INCLUDE_DIRS
		../../libobs)
	set(OBS_LIBRARIES
		libobs)
endif()

find_package(Pango REQUIRED)
find_package(Cairo REQUIRED)
find_package(Pangocairo REQUIRED)
if(WIN32)
	find_package(Pangowin32 REQUIRED)
endif()
find_package(Fontconfig REQUIRED)
find_package(Freetype REQUIRED)

include_directories(
	${OBS_INCLUDE_DIRS}
	${PANGO_INCLUDE_DIRS}
	${CAIRO_INCLUDE_DIRS}
	${PANGOCAIRO_INCLUDE_DIRS}
	${FREETYPE_INCLUDE_DIRS})
link_directories("D:/projects/text-rendering/build_release/install/lib")

set(text-pango_SOURCES
	text-pango.c
	text-pango.h
	text-utilities.h)

set(win32_static_LIBRARIES
	intl
	mini-fribidi
	pixman-1_static
	zlib
	harfbuzz
	libpng16_static
	expat
	usp10)
if(WIN32)
	set(PLATFORM_LIBRARIES ${win32_static_LIBRARIES})
endif()

add_library(text-pango MODULE
	${text-pango_SOURCES})
target_link_libraries(text-pango
	${OBS_LIBRARIES}
	${CAIRO_LIBRARIES}
	${PANGO_LIBRARIES}
	${PANGOWIN32_LIBRARIES}
	${PANGOCAIRO_LIBRARIES}
	${FREETYPE_LIBRARIES}
	${FONTCONFIG_LIBRARIES}
	${PLATFORM_LIBRARIES}) # win only currently
target_compile_definitions(text-pango PRIVATE ${CAIRO_C_FLAGS})


if(STANDALONE_PLUGIN)
	install(TARGETS text-pango 
		LIBRARY DESTINATION obs-plugins/64bit/
	)
	install(DIRECTORY data/common/ DESTINATION data/obs-plugins/text-pango)
	# Platform specific data, like fontconfig in win32
	if(WIN32)
		install(FILES $<TARGET_PDB_FILE:${PROJECT_NAME}> DESTINATION obs-plugins/64bit/ OPTIONAL)
		install(DIRECTORY data/win32/ DESTINATION data/obs-plugins/text-pango)
	endif()
else()
	install_obs_plugin_with_data(text-pango data/common)
	if(WIN32)
		install_obs_plugin_with_data(text-pango data/win32)
	endif()

endif()


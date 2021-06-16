# - Try to find FONTCONFIG
# Once done this will define
#
#  FONTCONFIG_ROOT_DIR - Set this variable to the root installation of FONTCONFIG
#  FONTCONFIG_FOUND - system has FONTCONFIG
#  FONTCONFIG_INCLUDE_DIRS - the FONTCONFIG include directory
#  FONTCONFIG_LIBRARIES - Link these to use FONTCONFIG
#
#  Copyright (c) 2008 Joshua L. Blocher <verbalshadow at gmail dot com>
#  Copyright (c) 2012 Dmitry Baryshnikov <polimax at mail dot ru>
#  Copyright (c) 2013 Michael Pavlyshko <pavlushko at tut dot by>
#
# Distributed under the OSI-approved BSD License
#

find_package(PkgConfig)
pkg_check_modules(PC_FONTCONFIG fontconfig QUIET)
if(PC_FONTCONFIG_FOUND)
	find_package_handle_standard_args(Fontconfig DEFAULT_MSG
		PC_FONTCONFIG_INCLUDE_DIRS PC_FONTCONFIG_LIBRARIES
	)

	mark_as_advanced(PC_FONTCONFIG_FOUND)
	set(FONTCONFIG_INCLUDE_DIRS ${PC_FONTCONFIG_INCLUDE_DIRS})
	set(FONTCONFIG_LIBRARIES ${PC_FONTCONFIG_LIBRARIES})
	set(FONTCONFIG_LIBRARY_DIRS ${PC_FONTCONFIG_LIBRARY_DIRS})
	return()
endif()

SET(_FONTCONFIG_ROOT_HINTS
    $ENV{FONTCONFIG}
    ${CMAKE_FIND_ROOT_PATH}
    ${FONTCONFIG_ROOT_DIR}
) 

SET(_FONTCONFIG_ROOT_PATHS
    $ENV{FONTCONFIG}/src
    /usr
    /usr/local
)

SET(_FONTCONFIG_ROOT_HINTS_AND_PATHS
    HINTS ${_FONTCONFIG_ROOT_HINTS}
    PATHS ${_FONTCONFIG_ROOT_PATHS}
)

FIND_PATH(FONTCONFIG_INCLUDE_DIR
    NAMES
        "fontconfig/fontconfig.h"
    HINTS
        ${_FONTCONFIG_INCLUDEDIR}
        ${_FONTCONFIG_ROOT_HINTS_AND_PATHS}
    PATH_SUFFIXES
        include
)  


FIND_LIBRARY(FONTCONFIG_LIBRARY
    NAMES
        fontconfig
    HINTS
        ${_FONTCONFIG_LIBDIR}
        ${_FONTCONFIG_ROOT_HINTS_AND_PATHS}
    PATH_SUFFIXES
        "lib"
        "local/lib"
)

SET(FONTCONFIG_LIBRARIES
    ${FONTCONFIG_LIBRARY}
)

SET(FONTCONFIG_INCLUDE_DIRS
    ${FONTCONFIG_INCLUDE_DIR}
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Fontconfig
    REQUIRED_VARS FONTCONFIG_LIBRARIES FONTCONFIG_INCLUDE_DIRS
    FAIL_MESSAGE "Could NOT find FONTCONFIG, try to set the path to FONTCONFIG root folder in the system variable FONTCONFIG"
)

MARK_AS_ADVANCED(FONTCONFIG_INCLUDE_DIR FONTCONFIG_INCLUDE_DIRS FONTCONFIG_LIBRARY FONTCONFIG_LIBRARIES)

find_package(PkgConfig)
pkg_check_modules(PC_PANGO pango QUIET)

find_path(PANGO_INCLUDE_DIR
    NAMES
        pango/pango.h
    HINTS
        ${PC_PANGO_INCLUDEDIR}
        ${PC_PANGO_INCLUDE_DIRS}
)

find_library(PANGO_LIBRARY
    NAMES
        pango libpango pango-1.0
    HINTS
        ${PC_PANGO_LIBDIR}
        ${PC_PANGO_LIBRARIES}
    PATH_SUFFIXES
        pango
)
find_package(PkgConfig)
pkg_check_modules(PC_GLIB REQUIRED glib-2.0)
pkg_check_modules(PC_GOBJECT REQUIRED gobject-2.0)
pkg_check_modules(PC_GMODULE REQUIRED gmodule-2.0)

list(APPEND PANGO_LIBRARY ${PC_GLIB_LIBRARIES})
list(APPEND PANGO_INCLUDE_DIR ${PC_GLIB_INCLUDE_DIRS})
list(APPEND PANGO_LIBRARY ${PC_GOBJECT_LIBRARIES})
list(APPEND PANGO_INCLUDE_DIR ${PC_OBJECT_INCLUDE_DIRS})
list(APPEND PANGO_LIBRARY ${PC_GMODULE_LIBRARIES})
list(APPEND PANGO_INCLUDE_DIR ${PC_GMODULE_INCLUDE_DIRS})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PANGO DEFAULT_MSG 
    PANGO_LIBRARY PANGO_INCLUDE_DIR
)

mark_as_advanced(PANGO_INCLUDE_DIR PANGO_LIBRARY)
set(PANGO_INCLUDE_DIRS ${PANGO_INCLUDE_DIR})
set(PANGO_LIBRARIES ${PANGO_LIBRARY})

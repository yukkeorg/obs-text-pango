find_package(PkgConfig)
pkg_check_modules(PC_PANGOCAIRO pangocairo QUIET)

FIND_PATH(PANGOCAIRO_INCLUDE_DIR
    NAMES
        pango/pangocairo.h
    HINTS
        ${PC_PANGOCAIRO_INCLUDEDIR}
        ${PC_PANGOCAIRO_INCLUDE_DIRS}
)

FIND_LIBRARY(PANGOCAIRO_LIBRARY
    NAMES
        pangocairo libpangocairo pangocairo-1.0
    HINTS
        ${PC_PANGOCAIRO_LIBDIR}
    PATH_SUFFIXES
        pango
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Pangocairo DEFAULT_MSG
    PANGOCAIRO_LIBRARY PANGOCAIRO_INCLUDE_DIR
)

MARK_AS_ADVANCED(PANGOCAIRO_INCLUDE_DIR PANGOCAIRO_LIBRARY)
set(PANGOCAIRO_INCLUDE_DIRS ${PANGOCAIRO_INCLUDE_DIR})
set(PANGOCAIRO_LIBRARIES ${PANGOCAIRO_LIBRARY})

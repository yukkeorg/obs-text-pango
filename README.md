Text Source using Pango for OBS Studio
======================================

This plugin provides a text source for OBS Studio. The text is layed out
and rendered using Pango.

Current Features
----------------

* Text alignment
* Text color
  * Colors for top and bottom of the text to create gradients
* Outline
  * Configurable width of the outline
  * Configurable color of the outline
* Drop Shadow
  * Configurable offset of the drop shadow from the text
  * Configurable color for the drop shadow
* Vertical Text
* Reading from the end of a file
	* Chat log mode (Last X lines from file)
* Per Line gradients

Unimplemented features
----------------------
* Read from file

Considering Features
----------------
* Custom text width
  * Word wrapping

Build
-----

You can either build the plugin as a standalone project or integrate it
into the build of OBS Studio (untested). Currently this is very helterskelter
in order to support static compilation of most dependencies.

Building it as a standalone project follows the standard cmake approach.
Create a new directory and run 
`cmake ... <path_to_source> -DCMAKE_INSTALL_PREFIX=<path_to_deps_dir>` for
whichever build system you use (only ninja tested). You may have to set 
the `OBS_DIR` environment variable to the location of the OBS source tree
and adjust the PATH_SUFFIXES as appropriate for your build directory.

alternately set `CMAKE_LIBRARY_PATH` and `CMAKE_INCLUDE_PATH` to include 
the path to libobs/libobs.h and libobs/libobs.lib

To integrate the plugin into the OBS Studio build put the source into a
subdirectory of the `plugins` folder of OBS Studio and add it to the
CMakeLists.txt.
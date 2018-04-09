#!/usr/bin/env bash

# Uses otoolr.py, copies and localizes all dependencies of the given plugin (and ignores libobs)

base_lib=`basename "$1"`
~/otoolr.py "$1" | grep -vF '/System/Lib' |\
	grep -vF '/usr/lib' | grep -vF "$base_lib" | grep -vF "libobs.0.dylib" > /tmp/$$.tmp

# prime all our libs
while read lib; do
	cp -n "$lib" ./deps/
done < /tmp/$$.tmp

while read lib; do
	local_lib=`basename "$lib"`
	chmod u+w "./deps/$local_lib"

		# xargs -L1 dirname | sort | uniq |\
	changes=$(otool -L "$lib" | tail +3 | grep -vF '/System/Lib' |\
		grep -vF '/usr/lib' | grep -v  '^\./' | sed 's/ .*$//' |\
	while read sublib; do
		sublib_name=`basename "$sublib"`
		echo -ne " -change \"$sublib\" \"@rpath/deps/$sublib_name\""
	done)
	if [ -n "$changes" ]; then
		# Beware all ye who use this script
		eval "install_name_tool $changes ./deps/$local_lib"
		# install_name_tool ${changes} ./deps/$local_lib
	fi
done < /tmp/$$.tmp

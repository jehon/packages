#!/usr/bin/env bash

file="$1"

# Thanks to https://askubuntu.com/a/1152748/638656

if ! type gio ; then
	echo "goi not found"
	exit 1
fi

if gio info "$file" | grep "metadata::trusted:" ; then
	echo "Icon already trusted  $file"
	exit 0
fi

echo "Trusting $file"
gio set "$file" "metadata::trusted" "yes"

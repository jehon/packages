#!/usr/bin/env bash

# Thanks to https://askubuntu.com/a/228588/638656

if [ "$2" = "" ]; then
	cat <<-EOL
		1: file
		2:
		- 0 = 90CounterCLockwise and Vertical Flip (default)
		- 1 = 90Clockwise
		- 2 = 90CounterClockwise
		- 3 = 90Clockwise and Vertical Flip
	EOL
	exit
fi

filename="${1%.*}"
extension="${1##*.}"
TARGET="$filename-rotated.$extension"

echo "Target: $TARGET"

# https://stackoverflow.com/a/38993717/1954789

set -o xtrace
ffmpeg -i "$1" \
	-c:a copy -vf "transpose=$2" -crf 18 \
	"$TARGET"
exiftool -TagsFromFile "$1" "$TARGET"

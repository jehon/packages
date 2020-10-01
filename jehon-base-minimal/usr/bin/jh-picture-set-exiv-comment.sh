#!/bin/sh

if [ "$2" = "" ]; then
	echo "Usage: $0 'comment' files"
	exit 255
fi

DATA="$1"
shift

if [ "$DATA" = "" ]; then
	echo "No data given as [1]"
	exit 1
fi

for f in "$@"; do
	if [ -d "$f" ]; then
		echo "Skipping folder $f"
		continue
	fi
	exiv2 -v modify -M"set Exif.Photo.UserComment $DATA" "$f"
done

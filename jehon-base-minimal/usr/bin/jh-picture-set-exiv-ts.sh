#!/bin/sh

if [ "$2" = "" ]; then
	echo "Usage: $0 '2018:01:02 03:04:05' files"
	exit 255
fi

TS="$1"
shift

check() {
	# Char are counted from 1
	# shellcheck disable=SC2003 # (expr is outdated)
	C="$( expr index "$TS" "$1" 1 )"
	if [ "$C" != ":" ]; then
		echo "Separator ':' not found at $1 - found $C of $TS"
		exit 1
	fi
}

if [ "$TS" = "" ]; then
	echo "No TS given as [1]"
	exit 1
fi

check 5
check 8

check 14
check 17

for f in "$@"; do
	if [ -d "$f" ]; then
		echo "Skipping folder $f"
		continue
	fi
	exiv2 -v modify -M"set Exif.Photo.DateTimeOriginal $TS" "$f"
done

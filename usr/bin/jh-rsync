#!/usr/bin/env bash

if [ "$1" = "" ]; then
	echo "No source specified [1]"
	exit 1
fi
if [ "$2" = "" ]; then
	echo "No destination specified [2]"
	exit 1
fi

SRC="$1"
DST="$2"
shift
shift

#echo "Source" "$SRC"
#echo "Destination" "$DST"
#echo "Extra parameters" "${@}"
#echo "Command Line Parameters: $JH_SSH"

# Fix the path to avoid having the custom ssh command
export PATH=/sbin:/usr/sbin:/bin:/usr/bin

# Transform into an array
read -r -a JH_SSH <<< "$JH_SSH"

/usr/bin/rsync \
	"${JH_SSH[@]}" \
	--recursive --links --times \
	--omit-dir-times \
	--itemize-changes \
	--modify-window=2 \
	--exclude ".Trash*" \
	--exclude "Trash*" \
	--exclude lost+found  \
	--exclude desktop.ini \
	--exclude Thumbs.db \
	--exclude "*.lock" \
	--exclude "\$RECYCLE.BIN" \
	--exclude "\$Recycle.Bin" \
	--exclude "*~" \
	--exclude "System Volume Information" \
	--exclude "#*#.*" \
	--exclude "*.ext" \
	--exclude "tmp" \
	"$@" \
	"$SRC" "$DST"

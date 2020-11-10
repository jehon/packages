#!/usr/bin/env bash

# Usage:
# - <file>
# - "uninstall" <file> [tag]

#
# File format example:
#
# File: /etc/ssh/ssh_config
# Tag: minimal_ssh_config
#

if [ "$1" == "uninstall" ]; then
	INCLUDE=""
	FILE="$2"
	TAG="$3"
	echo "Uninstalling from $FILE with $TAG"
else
	INCLUDE="$1"
	if [ ! -f "$INCLUDE" ]; then
		echo "Include file does not exists [1]: $INCLUDE" >&2
		exit 255
	fi

	TAG=""
	# s="$( basename "$s" )"
	# ${s%.*}
	while read -r line; do
		if [[ $line =~ \#[[:blank:]]+Tag:[[:blank:]]*(.*) ]] ; then
			TAG=${BASH_REMATCH[1]};
		fi
		if [[ $line =~ \#[[:blank:]]+File:[[:blank:]]*(.*) ]] ; then
			FILE=${BASH_REMATCH[1]};
		fi
		if [[ $line =~ \#[[:blank:]]+Empty:[[:blank:]]*(.*) ]] ; then
			EMPTY=${BASH_REMATCH[1]};
		fi
	done < $INCLUDE
fi

TAG_BEGIN="### JEHON BEGIN ${TAG} ###"
TAG_END="### JEHON END ${TAG} ###"

# echo "File:      $FILE (from $INCLUDE)"
# echo "Tag:       $TAG"
# echo "Tag begin: $TAG_BEGIN"
# echo "Tag end:   $TAG_END"

if [ "$FILE" = "" ]; then
	echo "Error parsing file $INCLUDE: no 'File: xxx' tag found" >&2
	exit 255
fi

if [ ! -r "$FILE" ]; then
	if [ -z "$EMPTY"]; then
		echo "File $FILE does not exists, bailing out..." >&2
		exit 0
	fi
fi

BACKUP="$FILE-before-patch-file"
cp "$FILE" "$BACKUP"

{
	sed "/$TAG_BEGIN/,/$TAG_END/d" "$BACKUP"
	if [ "$INCLUDE" != "" ]; then
		echo "$TAG_BEGIN"
		echo "# Live source: $INCLUDE"
		if [ -r "$INCLUDE" ]; then
			# Include file
			cat "$INCLUDE"
		else
			echo "Could not read input file $INCLUDE" >&2
		fi
		# if ! test -t 0 ; then
		# 	# We are in a pipe, include stdin
		# 	while read -t 0.001 -r line ; do
		# 		echo "$line"
		# 	done
		# fi

		echo "$TAG_END"
	fi
} > "$FILE"

echo "${FILE}:${TAG}"

#!/usr/bin/env bash

# Based on Image Magic "convert" tool

if [ "$2" = "" ]
then
	echo "Usage: $0 sizeTarget image/directory"
	echo "SizeTarget: 900x900>"
	echo "SizeTarget: 25%"
	echo "see man convert"
	exit 0
fi

GEOMETRY=$1

function reduce() {
	echo -n "$1"
	MIME=$(mimetype -b "$1" )
	if [[ $MIME = image/* ]]; then
		echo -n ""
	else
		echo " is not a picture [$MIME]"
		return
	fi

	/usr/bin/convert -geometry "$GEOMETRY" "$1" "$1.tmp"
	SO=$( stat -c%s "$1" )
	SN=$( stat -c%s "$1.tmp" )
	SCO=$(( SO * 100 ))
	SCN=$(( SN * 110 ))

	if [ $SCN -lt $SCO  ]; then
		echo " is resized: $SO vs. $SN"
		rm "$1"
		mv "$1.tmp" "$1"
	else
		echo " is skipped"
		rm "$1.tmp"
	fi
}

function treatOne() {
	if [ "$(basename "$1")" = "/" ] ; then return 0; fi;
	if [ "$(basename "$1")" = "." ] ; then return 0; fi;
	if [ "$(basename "$1")" = ".." ] ; then return 0; fi;
	if [ -f "$1" ]
	then
		reduce "$1"
	fi
	if [ -d "$1" ]
	then
                echo "Directory $1"
		for FILE in "$1"/* ;
		do
			if [ "$FILE" = "$1/*" ]; then return 0; fi;
			treatOne "$FILE"
		done
	fi
}

echo "Treating $2"
treatOne "$2"

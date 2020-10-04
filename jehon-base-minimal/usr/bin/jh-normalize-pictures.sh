#!/usr/bin/env bash

EXIF="/usr/bin/exif"
if [[ ! -x "$EXIF" ]]; then
	echo "EXIF $EXIF not found runnable"
	exit 255
fi

if [[ ${#@} < 1 ]]; then
	echo "Missing first parameter: comment"
	exit 1
fi

function treatOneJPG() {
	# 1: comment
	# 2: file
	FILE="$2"
	NFILE="$(basename "$FILE")"
	DFILE="$(dirname "$FILE")"
	COMP="$($EXIF -t 0x0132 "$FILE" 2>/dev/null | grep "Value" | cut -d ':' -f 2- )"
	if [ "$COMP" = "" ]; then
		DATE="$(date -r "$FILE" "+%F %Hh%Mm%S" )"
		echo "no data $FILE: $COMP"
		treatOneOther "$1" "$2"
		return
	else
		if [ "$COMP" = " 0000:00:00 00:00:00" ]; then
			treatOneOther "$1" "$2"
			return
		else
			DATE="$(echo $COMP | cut -d ' ' -f 1 | tr ':' '-' )"
			TIME="$(echo $COMP | cut -d ' ' -f 2 )"
			HUR="$(echo $TIME | cut -d ':' -f 1 )"
			MIN="$(echo $TIME | cut -d ':' -f 2 )"
			SEC="$(echo $TIME | cut -d ':' -f 3 )"
			DATE="${DATE} ${HUR}-${MIN}-${SEC}"
		fi
	fi

	if [ "$1" = "" ]; then
		NEWFILE="$DFILE/${DATE} - $NFILE"
	else
		EXT=${2/^.+/.}
		NEWFILE="$DFILE/${DATE} $1.$EXT"
	fi
	echo "pict : $FILE -\> $NEWFILE"
	if [ "$FILE" != "$NEWFILE" ]; then
		mv -i "$FILE" "$NEWFILE";
	fi
}

function treatOneOther() {
	# 1: subname
	# 2: file
	FILE="$2"
	NFILE="$( basename "$FILE" )"
	DFILE="$( dirname "$FILE" )"
	DATE="$( date -r "$FILE" "+%F %H.%M.%S" )"
	if [ "$1" = "" ]
	then
		NEWFILE="$DFILE/${DATE} - $NFILE"
	else
		NEWFILE="$DFILE/${DATE} $1 - $NFILE"
	fi
	echo "other: $FILE -\> $NEWFILE"
	if [ "$FILE" != "$NEWFILE" ]; then
		# true
		mv -i "$FILE" "$NEWFILE";
	fi
}

function treatOne() {
	COMMENT="$1"
	T1=${1//\//_}
	if [ "$T1" != "$1" ]; then
		C2="$2"
		R2="$( realpath "$C2")"
		C2="$( dirname "$R2")"
		C2=${C2#$COMMENT}
		C2=${C2#\/}
		C3=${C2//\// - }
		COMMENT="$C3"
	fi
	echo "COMMENT: [$1]$R2 '$COMMENT'"

	# endwith
	if [ ${2%.jpg} != $2 ]; then
		treatOneJPG "$COMMENT" "$2"
		return 0
	fi
	# endwith
	if [ ${2%.JPG} != $2 ]; then
		treatOneJPG "$COMMENT" "$2"
		return 0
	fi
	treatOneOther "$1" "$2"
}

if  [ "$2" == "" ]; then
	ls *.jpg *.JPG | while read FILE
	do
		treatOne "$1" "$FILE"
	done

	ls *.avi *.AVI *.mov *.MOV | while read FILE ; do
		treatOne "$1" "$FILE"
	done
else
	treatOne "$1" "$2"
fi

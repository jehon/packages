#!/bin/sh

set -e

# TODO: treat more cases

treatOne () {
	VINFO=$(ffmpeg -i "$1" 2>&1 | grep "Video:" )
	if [ "$VINFO" = "" ]; then return; fi
	if echo "$VINFO" | grep -q -E " (mjpeg|gif|ansi)[, ]"; then return; fi
	if echo "$VINFO" | grep -q -E " (mpeg4|h264) "; then return; fi

	# Extract extension -> new name
	ORIG=$( basename "$1" )
	BASENAME="${ORIG%.*}"
	CONVERTED="$BASENAME.converted.mkv"

	if echo "$VINFO" | grep -q " msmpeg4v3 "
	then
		if [ -f "$CONVERTED" ]; then return; fi
		echo ""
		echo "[treatme - msmpeg4v3] $1"
		#echo "VINFO: $VINFO"
		# --bitrate --preset veryslow
		# test: -ss 5:00 -t 10
		#ffmpeg -i "$1" -map 0 -c copy -c:v mpeg4 -b:v 1000 "$CONVERTED"

		#ffmpeg -i "$1" 2>&1 | grep "video"
		#ffmpeg -i "$BASENAME.converted.mkv" 2>&1 | grep "video"
		return
	fi
	if echo "$VINFO" | grep -q " rv40, "
	then
		echo ""
		echo "[treatme - rv40] $1"
		return
	fi
	if echo "$VINFO" | grep -q " mpeg1video, "
	then
		echo ""
		echo "[treatme - mpeg1video] $1"
		return
	fi
	echo ""
	echo "[unknown] $1: $VINFO"
}

DIR="/volume3/video/"
if [ "$1" != "" ]; then
	DIR="$1"
fi

find "$DIR" -type f -size +100000k \
	| grep -v "@eaDir" \
	| grep -v "VIDEO_TS" \
	| grep -v "AUDIO_TS" \
	| grep -v "Originaux" \
	| while read -r F; do
		treatOne "$F"
	done

#!/usr/bin/env bash

set -e

case "$1" in
	"10x15" )
		OPT=""
		OPT="-x 108 -y 152"
		;;
	"15x10" )
		OPT="-x 151 -y 101"
		;;
	"14x10" )
		OPT="-x 135 -y 100"
		;;
	"14x9" )
		OPT="-x 140 -y 90"
		;;
	"15x21" )
		OPT="-x 150 -y 210"
		;;
	"s" )
		OPT="-x 200 -y 195"
		;;
	*)
		echo "Unsupported"
		exit 1
esac

scan() {

	RES="$(date +"%Y-%m-%d_%H-%M-%S")"

	echo ""
	echo "Scanning to $RES..."

	# https://askubuntu.com/a/575213/638656
	scanimage --progress  --format tiff \
		--mode Color --resolution 300 \
		$OPT \
		| convert - -quality 75 "$RES.jpg"

	echo ""
	echo "Scanning done!"
	echo "Launching eog..."

	eog "$RES.jpg"
	echo "... done"
}

while true; do
	scan
	# read -r L
done

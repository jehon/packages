#!/usr/bin/env bash

set -o errexit

OPT="-x $1 -y $2"

case "$1" in
"10x15")
	OPT="-x 108 -y 152"
	;;
"17x10")
	OPT="-x 170 -y 101"
	;;
"15x10")
	OPT="-x 151 -y 101"
	;;
"14x10")
	OPT="-x 135 -y 100"
	;;
"14x9")
	OPT="-x 140 -y 90"
	;;
"13x10")
	OPT="-x 130 -y 100"
	;;
"15x21")
	OPT="-x 150 -y 210"
	;;
"s")
	OPT="-x 200 -y 195"
	;;
"a4")
	OPT="-x 205 -y 295"
	;;
"a5")
	OPT="-x 205 -y 135"
	;;
esac

if [ -z "$OPT" ]; then
	echo "Unsupported"
	exit 1
fi

# Transform into an array
read -r -a OPT <<<"$OPT"

scan() {

	RES="$(date +"%Y-%m-%d_%H-%M-%S")"

	echo ""
	echo "Scanning to $RES..."

	# https://askubuntu.com/a/575213/638656
	scanimage --progress --format tiff \
		--mode Color --resolution 300 \
		"${OPT[@]}" |
		convert - -quality 75 "$RES.jpg"

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

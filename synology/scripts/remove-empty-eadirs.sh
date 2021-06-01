#!/bin/sh

set -o errexit

if [ "$1" != "" ]; then
	P="$1"
else
	P=$(pwd)
fi

isEmpty() {
	#echo "? $1"
	EMPTY="1"
	for L in "$1"/*; do
		if [ ! -e "$L" ]; then
			# There is no file in there ($L = ".../*")
			continue
		fi
		BN=$(basename "$L")
		DN=$(dirname "$L")
		if [ "$BN" = "Thumbs.db@SynoEAStream" ]; then
			# Don't take that file into account (is present everywhere)
			EMPTY="0"
			continue
		fi
		if [ -f "$DN/../$BN" ]; then
			EMPTY="0"
			continue
		fi
		if [ ! -f "$DN/../$BN" ]; then
			# No matching file above
			rm -fr "$L"
			continue
		fi
		#echo "???? $L"
		EMPTY="0"
	done
	if [ "$EMPTY" = "1" ]; then
		echo "== empty found: $1"
		ls "$1/"
		rmdir "$1"
	fi
}

checkThisOne() {
	for L in "$1"/*; do
		if [ -d "$L" ]; then
			BN=$(basename "$L")
			if [ "$BN" = "@eaDir" ]; then
				isEmpty "$L"
			else
				checkThisOne "$L"
			fi
		fi
	done
}

checkThisOne "$P"

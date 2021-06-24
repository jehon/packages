#!/usr/bin/env bash

shopt -s extglob

if [ -z "$1" ]; then
	echo "Max age in days (1): $1"
	exit 255
fi

PREFIX=""
AGE="$1"

if [ -n "$2" ]; then
	PREFIX="$1"
	AGE="$2"
fi

OLD=$(date -d "now - $AGE days" '+%Y-%m-%d')

while read -r DIR; do
	F=$(basename "$DIR")
	if [ "$F" = "." ]; then continue; fi
	if [ "$F" = ".." ]; then continue; fi
	if [[ $F =~ .*(20[0-9][0-9]-[0-1][0-9]-[0-5][0-9]).* ]]; then
		D="${BASH_REMATCH[1]}"
		if [[ "$D" < "$OLD" ]]; then
			echo "too old $D: $F"
			rm -fr "$DIR"
		fi
	else
		echo "It does not match: $F"
	fi
done < <(exec find -maxdepth 1 -name "$PREFIX*20[0-9][0-9]-[0-1][0-9]-[0-5][0-9]*")

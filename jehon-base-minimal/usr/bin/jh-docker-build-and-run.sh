#!/usr/bin/env bash

DCKFILE="$1"
shift

DOCKERID=$(docker build -f "$DCKFILE" . \
	| tee >(cat >&3) \
	| grep "Successfully built" \
	| cut -f 3 -d " " \
	)

if [ "$DOCKERID" = "" ]; then
	echo "Could not find docker id in output?"
	exit 255
fi

echo "Running $*"

docker run --rm \
	-e LOGLEVEL="$LOGLEVEL" \
	-e IN_DOCKER=1 \
	--mount "source=$(pwd),target=/app,type=bind" \
	"$DOCKERID" "$@"

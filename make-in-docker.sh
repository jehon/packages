#!/usr/bin/env bash

SWD="$(dirname "$(realpath "$0")")"
echo "SWD: $SWD"

docker run \
	--mount "source=${SWD},target=/app,type=bind" \
	jehon/jehon-docker-build \
	make "$@"

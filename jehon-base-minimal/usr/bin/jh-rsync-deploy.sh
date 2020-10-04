#!/usr/bin/env bash

SRC="$1"
DST="$2"
shift
shift

jh-rsync.sh \
	"$SRC" "$DST" \
	--delete --max-delete=1000 --delete-excluded \
	--perms \
	--exclude ".git" \
	--exclude "tmp" \
	"$@"

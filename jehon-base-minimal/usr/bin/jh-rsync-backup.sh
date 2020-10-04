#!/usr/bin/env bash

SRC="$1"
DST="$2"
shift
shift

jh-rsync.sh \
	"$SRC/" "$DST" \
	--progress \
	--one-file-system \
	--no-owner --no-group  --chmod=ugo=rwX \
	--delete --delete-excluded \
	--filter ": .jhrsync-filter" \
	--filter ":- .gitignore" \
	"$@"

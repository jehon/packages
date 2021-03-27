#!/usr/bin/env bash

if [ ! -r ".music" ]; then
	echo ".music does not exists here"
	exit 1
fi

jh-rsync.sh \
	/home/jehon/gvfs/smb-share\:server\=192.168.1.9\,share\=music/ \
	. \
	--exclude .music \
	--exclude "#recycle" \
	--delete

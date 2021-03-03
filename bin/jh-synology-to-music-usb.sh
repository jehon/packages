#!/usr/bin/env bash

jh-rsync.sh \
	gvfs/smb-share\:server\=192.168.1.9\,share\=music/ \
	/media/jehon/HONLET \
	\
	--exclude "#recycle" \
	--delete


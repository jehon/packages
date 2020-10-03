#!/usr/bin/env bash

set -e
set -x

clear

ROOT="/media/$(whoami)/usb_drive/synology"

jhrsync() {
	TARGET=$ROOT/$1
	if [ ! -d "$TARGET" ]; then
		mkdir "$TARGET"
	fi

	rsync --recursive --links --times --perms --inplace --itemize-changes --progress --delete \
		--exclude "@eaDir" \
		--exclude "#recycle" \
		--delete-excluded \
		--chmod=ugo=rwX \
		"--rsync-path=/bin/rsync" "root@synology:/volume3/$1/" "$ROOT/$1"
}

jhrsync documents
jhrsync photo
jhrsync music
jhrsync downloads

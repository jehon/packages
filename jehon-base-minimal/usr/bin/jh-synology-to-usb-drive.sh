#!/usr/bin/env bash

set -e

ROOT="/media/$(whoami)/usb_drive/synology"

jhrsync() {
	TARGET=$ROOT/$1
	if [ ! -d "$TARGET" ]; then
		mkdir "$TARGET"
	fi

	rsync --recursive --links --times --no-perms --inplace --itemize-changes --progress --delete \
		--exclude "@eaDir" \
		--exclude "#recycle" \
		--delete-excluded \
		--chmod=ugo=rwX \
		"--rsync-path=/bin/rsync" "root@synology:/volume3/$1/" "$ROOT/$1"
}

echo "************************************************"
echo "* Don't forget to launch with systemd-inhibit  *"
echo "************************************************"
echo systemd-inhibit "$0" "$@"


jhrsync documents
jhrsync photo
jhrsync music
jhrsync downloads

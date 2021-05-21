#!/usr/bin/env bash

set -e

ROOT="/media/$(whoami)/usb_drive/synology"

syncThis() {
	TARGET=$ROOT/$1
	if [ ! -d "$TARGET" ]; then
		mkdir "$TARGET"
	fi

	SSHPASS="$JH_NAS_ADMIN_PASS" sshpass -e \
		rsync --recursive --links --times --no-perms --inplace --itemize-changes --progress --delete \
		--exclude "@eaDir" \
		--exclude "#recycle" \
		--delete-excluded \
		--chmod=ugo=rwX \
		"--rsync-path=/bin/rsync" "$JH_NAS_ADMIN_USER@$JH_NAS_IP:/volume3/$1/" "$ROOT/$1"
}

echo "************************************************"
echo "* Don't forget to launch with systemd-inhibit  *"
echo "************************************************"
echo systemd-inhibit "$0" "$@"

syncThis documents
syncThis photo
syncThis music
syncThis downloads

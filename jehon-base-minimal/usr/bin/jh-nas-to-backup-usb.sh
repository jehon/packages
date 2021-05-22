#!/usr/bin/env bash

set -e

. jh-ensure-network

ROOT="/media/$(whoami)/usb_drive/synology"

syncThis() {
	TARGET=$ROOT/$1
	if [ ! -d "$TARGET" ]; then
		mkdir "$TARGET"
	fi

	SSHPASS="$JH_NAS_PASS" sshpass -e \
		rsync \
		-e "ssh" \
		--recursive --links --times --no-perms --inplace \
		--itemize-changes --progress \
		--delete --delete-excluded \
		--exclude "@eaDir" \
		--exclude "#recycle" \
		--chmod=ugo=rwX \
		"$JH_NAS_USER@$JH_NAS_IP::$1/" "$ROOT/$1"
}

echo "************************************************"
echo "* Don't forget to launch with systemd-inhibit  *"
echo "************************************************"
echo systemd-inhibit "$0" "$@"

syncThis documents
syncThis photo
syncThis music
syncThis downloads


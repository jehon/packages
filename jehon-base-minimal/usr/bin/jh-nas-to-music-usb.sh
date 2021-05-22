#!/usr/bin/env bash

set -e

if [ "$1" = "-f" ]; then
	echo "Forcing sync here..."
	touch .music
fi

if [ ! -r ".music" ]; then
	echo ".music does not exists here"
	echo "You must create .music to allow this sync"
	echo "Or specify -f"
	exit 1
fi

. jh-ensure-network

SSHPASS="$JH_NAS_PASS" sshpass -e \
	rsync \
	-e "ssh" \
	--recursive --links --times --no-perms --inplace \
	--itemize-changes --progress \
	--delete --delete-excluded \
	--exclude .music --filter "P .music" \
	--exclude "#recycle" \
	"$JH_NAS_USER@$JH_NAS_IP::music/" .

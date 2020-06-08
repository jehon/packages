#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
	echo "Need hostname as [1]"
	exit 255
fi

echo "*** Installing jehon-env-home"
ssh "root@$1" apt install -y --allow-unauthenticated jehon-env-home


echo "*** Configuring auto-backup"
## Get the key
KEY=$( ssh "root@$1" cat /etc/jehon/restricted/synology_auto.pub )
AF="synology/ssh/root/authorized_keys"
cp "$AF" "$AF.tmp"
(
	echo ""
	echo "# $(basename "$0") for $1"
	echo -n "# On "
	date
	grep "# Template backup #" "$AF.tmp" | sed "s/# Template backup # //g" \
		| sed "s/%HOSTNAME%/$1/" \
		| sed "s^%KEY%^$KEY^"
) >> "$AF"

## publish the new authorized keys
make deploy-synology-ssh

## run a first backup
ssh "root@$1" /usr/sbin/jh-backup-computer

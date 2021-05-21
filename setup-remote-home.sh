#!/usr/bin/env bash

set -e

if [ -z "$1" ]; then
	echo "Need hostname as [1]"
	exit 255
fi

echo "*** Installing jehon-env-home"
ssh "root@$1" apt install -y --allow-unauthenticated jehon-base-minimal

## run a first backup
ssh "root@$1" /usr/sbin/jh-backup-computer

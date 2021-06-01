#!/usr/bin/env bash

# 1: hostname
# 2: username

set -o errexit

if [ -z "$1" ]; then
	echo "Need hostname as [1]"
	exit 255
fi

if [ -z "$2" ]; then
	echo "Need username as [2]"
	exit 255
fi

if [ -z "$3" ]; then
	echo "Need password as [2]"
	exit 255
fi

sshpass -p"$3" scp start "$2@$1":/tmp/start

sshpass -p"$3" ssh "$2@$1" "chmod +x /tmp/start; sudo /tmp/start"

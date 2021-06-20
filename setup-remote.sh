#!/usr/bin/env bash

# 1: hostname
# 2: username

set -o errexit

# shellcheck source=/dev/null
. jh-lib

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

SSH_HOST="$1"
SSH_USER="$2"
SSH_PASS="$3"

header_start "Forget previous ssh key..."
ssh-keygen -f "/home/jehon/.ssh/known_hosts" -R "$SSH_HOST"
ssh-keygen -f "/home/jehon/.ssh/known_hosts" -R "$(dig +short "$SSH_HOST")"
jh-ping-ssh.sh "$SSH_HOST"
header_done

header_start "Run Start on remote $HOST..."
sshpass -p"$SSH_PASS" scp start "$SSH_USER@$SSH_HOST":/tmp/start
sshpass -p"$SSH_PASS" ssh "$SSH_USER@$SSH_HOST" "chmod +x /tmp/start; sudo /tmp/start"
header_done

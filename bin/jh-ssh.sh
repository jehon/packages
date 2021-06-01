#!/usr/bin/env bash

set -o errexit

debug() {
	if [[ -n "$DEBUG" ]]; then
		echo "$@"
	fi
}

if [ -z "$1" ]; then
	echo "Need target host as [1]"
	exit 255
fi
SSH_HOST="$1"
ORIGINAL_HOST="$SSH_HOST"
case "$SSH_HOST" in
*) ;;

esac

case "$2" in
root)
	SSH_USER="root"
	SSH_CMD="$3"
	shift
	;;
sftp)
	SFTP=sftp
	SSH_CMD=""
	;;
sftp-root)
	SSH_USER="root"
	SSH_CMD=""
	SFTP="sftp"
	;;
esac

SSH_USER="${SSH_USER:-root}"
SSH_PASS="${SSH_PASS:-password}"

#
#
# Let's go for real
#
#

H="[${ORIGINAL_HOST}]"
debug "$H - SSH_HOST: $SSH_HOST"
debug "$H - SSH_USER: $SSH_USER"
debug "$H - SSH_PASS: $SSH_PASS"

debug "$H Pinging host"
ping -c 1 "$SSH_HOST" >/dev/null
debug "$H Host is reachable"

debug "$H Launching ssh"
if [ -z "$SFTP" ]; then
	sshpass -p "$SSH_PASS" \
		ssh \
		-t \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		"$SSH_USER@$SSH_HOST" "$SSH_CMD"
else
	sshpass -p "$SSH_PASS" \
		sftp \
		-o StrictHostKeyChecking=no \
		-o UserKnownHostsFile=/dev/null \
		"$SSH_USER@$SSH_HOST" "$SSH_CMD"
fi
debug "$H SSH ended"

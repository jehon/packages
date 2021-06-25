#!/usr/bin/env bash

# 1: ip
# 2: username
# 3: password
# 4: hostname

set -o errexit

# shellcheck source=/dev/null
. jh-lib

# shellcheck source=/dev/null
. jh-secrets

SSH_HOST="$1"
SSH_USER="$2"
SSH_PASS="$3"
HOSTNAME="$4"

if [ -z "$SSH_HOST" ]; then
	echo "Need hostname as [1]"
	exit 255
fi

if [ -z "$SSH_USER" ]; then
	echo "Need username as [2]"
	exit 255
fi

if [ -z "$SSH_PASS" ]; then
	echo "Need password as [3]"
	exit 255
fi

header_start "Forget previous ssh key..."
jh-ssh-forget "$SSH_HOST"
jh-ping-ssh "$SSH_HOST"
header_done

header_start "Run Start on remote $SSH_HOST..."
sshpass -p"$SSH_PASS" scp start "$SSH_USER@$SSH_HOST":/tmp/start
sshpass -p"$SSH_PASS" ssh "$SSH_USER@$SSH_HOST" "chmod +x /tmp/start; sudo /tmp/start"
header_done

if [ -n "$HOSTNAME" ]; then
	header_start "Setting the hostname to $HOSTNAME"
	# shellcheck disable=SC2029
	ssh "root@$SSH_HOST" "hostnamectl set-hostname '$HOSTNAME'"
	header_done
fi

header_start "Setup password for user jehon"
echo "jehon:$JH_DEFAULT_PWD" | ssh root@"$SSH_HOST" chpasswd
printf "%s\n%s\n" "$JH_DEFAULT_PWD" "$JH_DEFAULT_PWD" | ssh root@"$SSH_HOST" smbpasswd -s -a jehon
header_done

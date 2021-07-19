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
HOSTNAME="$3"

if [ -z "$SSH_HOST" ]; then
	echo "Need hostname as [1]"
	exit 255
fi

if [ -z "$SSH_USER" ]; then
	echo "Need username as [2]"
	exit 255
fi

header_start "Forget previous ssh key..."
jh-ssh-ping "$SSH_HOST"
jh-ssh-update-key "$SSH_HOST"
header_done

header_start "Run Start on remote $SSH_HOST..."
# shellcheck disable=SC2029
ssh "$SSH_USER@$SSH_HOST" "wget https://raw.githubusercontent.com/jehon/packages/master/start; chmod +x start; sudo start \"$HOSTNAME\" \"$JH_DEFAULT_PWD\""
header_done

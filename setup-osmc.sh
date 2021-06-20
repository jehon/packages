#!/usr/bin/env bash

set -o errexit

# shellcheck source=/dev/null
. jh-lib

# shellcheck source=/dev/null
SSH_HOST="osmc"
SSH_USER="osmc"
SSH_PASS="osmc"

# header_start "Setup remote start..."
# ./setup-remote.sh $SSH_HOST "$SSH_USER" "$SSH_PASS"
# header_done

header_start "Sending files to osmc..."
sshpass -p "$SSH_PASS" scp "$JH_SECRETS_FOLDER"/crypted/osmc/osmc.env "$SSH_USER@$SSH_HOST":/home/osmc/osmc.env
sshpass -p "$SSH_PASS" scp jehon-base-minimal/usr/bin/jh-osmc-system-setup "$SSH_USER@$SSH_HOST":/home/osmc/
header_done

header_start "Configure..."
sshpass -p "$SSH_PASS" ssh "$SSH_USER@$SSH_HOST" ./jh-osmc-system-setup
header_done

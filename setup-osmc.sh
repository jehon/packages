#!/usr/bin/env bash

set -o errexit

# shellcheck source=/dev/null
. jh-lib

SSH_HOST="osmc"

header_start "Setup remote start..."
./setup-remote.sh $SSH_HOST osmc osmc
header_done

header_start "Install jehon-system-tv..."
scp "$JH_SECRETS_FOLDER"/osmc/jehon.env root@$SSH_HOST/etc/jehon/restricted/jehon.env
ssh "root@$SSH_HOST" jh-osmc-system-setup
header_done

#!/usr/bin/env bash

set -o errexit

# shellcheck source=/dev/null
. jh-lib

# shellcheck source=/dev/null
. "$JH_SECRETS_FOLDER"/crypted/osmc/osmc.env

# shellcheck source=/dev/null
SSH_HOST="osmc"
SSH_USER="osmc"
SSH_PASS="osmc"

OSMC_TMP="$JH_PKG_FOLDER/tmp/osmc"
mkdir -p "$OSMC_TMP"

header_start "Remove previous key"
jh-ssh-forget "$SSH_HOST"
jh-ping-ssh "$SSH_HOST"
header_done

# header_start "Setup remote start..."
# ./setup-remote.sh $SSH_HOST "$SSH_USER" "$SSH_PASS"
# header_done

header_start "Building config..."
envsubst <"$JH_PKG_FOLDER"/conf/osmc/sources.xml >"$OSMC_TMP/sources.xml"
envsubst <"$JH_PKG_FOLDER"/conf/osmc/passwords.xml >"$OSMC_TMP/passwords.xml"
envsubst <"$JH_PKG_FOLDER"/conf/osmc/jhKeymaps.xml >"$OSMC_TMP/jhKeymaps.xml"
header_done

header_start "Sending files to osmc..."
set -o xtrace
sshpass -p "$SSH_PASS" scp "$OSMC_TMP/"* "$SSH_USER@$SSH_HOST":/home/osmc/
header_done

header_start "Configure..."
sshpass -p "$SSH_PASS" ssh "$SSH_USER@$SSH_HOST" /bin/bash <<-EOS
    set -o errexit;
    cp --backup sources.xml /home/osmc/.kodi/userdata/;
    cp --backup passwords.xml /home/osmc/.kodi/userdata/;
    cp --backup jhKeymaps.xml /home/osmc/.kodi/userdata/keymaps/;

    chown osmc.osmc /home/osmc/.kodi/userdata/sources.xml;
    chown osmc.osmc /home/osmc/.kodi/userdata/passwords.xml;
    chown osmc.osmc /home/osmc/.kodi/userdata/keymaps/jhKeymaps.xml;
EOS
header_done

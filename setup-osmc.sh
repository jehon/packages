#!/usr/bin/env bash

set -o errexit

# shellcheck source=/dev/null
. jh-lib

SSH_HOST="osmc"

header_start "Setup remote start..."
./setup-remote.sh $SSH_HOST osmc osmc
header_done

header_start "Install jehon-system-tv..."
#
# TODO: copy jehon.env from secrets into /etc/jehon/restricted/jehon.env
# TODO: run jh-osmc-setup
# TODO: remove jehon-system-tv package
#

ssh "root@$SSH_HOST" -T <<EOS
	apt install jehon-system-tv
EOS
header_done

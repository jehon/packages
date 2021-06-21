#!/usr/bin/env bash

set -o errexit

# shellcheck source=/dev/null
. jh-lib

SSH_HOST="kiosk"

header_start "Remove previous key"
jh-ssh-forget "$SSH_HOST"
header_done

header_start "Setup remote start..."
./setup-remote.sh $SSH_HOST pi raspberry
header_done

header_start "Run kickstart from kiosk github"
ssh "root@$SSH_HOST" -T <<EOS
	cd /opt/
	wget https://raw.githubusercontent.com/jehon/kiosk/master/kickstart.sh -O /opt/kickstart.sh
	chmod +x /opt/kickstart.sh
	/opt/kickstart.sh && rm /opt/kickstart.sh
EOS
header_done

# TODO: copy fstab file from local repo

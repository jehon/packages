#!/usr/bin/env bash

clear

set -o errexit

# shellcheck source=/dev/null
. jh-lib

# shellcheck source=/dev/null
. jh-secrets

SSH_HOST="${JH_HOSTS_KIOSK['IP']}"

header_start "Remove previous key"
jh-ssh-forget "$SSH_HOST"
header_done

header_start "Setup remote start..."
./setup-remote.sh "$SSH_HOST" "${JH_HOSTS_KIOSK['USER']}" "${JH_HOSTS_KIOSK['PASS']}" "kiosk"
header_done

header_start "Run kickstart from kiosk github"
ssh "root@$SSH_HOST" -T <<EOS
	cd /opt/
	wget https://raw.githubusercontent.com/jehon/kiosk/master/kickstart.sh -O /opt/kickstart.sh
	chmod +x /opt/kickstart.sh
	/opt/kickstart.sh && rm /opt/kickstart.sh
EOS
header_done

"$JH_PKG_FOLDER"/bin/jh-kiosk-configure-shares kiosk

# TODO: copy fstab file from local repo
# TODO: copy config file from local repo

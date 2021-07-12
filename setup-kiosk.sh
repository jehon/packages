#!/usr/bin/env bash

clear

set -o errexit

# shellcheck source=/dev/null
. jh-lib

# shellcheck source=/dev/null
. jh-secrets

SSH_HOST="${JH_HOSTS_KIOSK['IP']}"
SSH_USER="${JH_HOSTS_KIOSK['USER']}"
SSH_PASS="${JH_HOSTS_KIOSK['PASS']}"

SSH_USER="pi"
SSH_PASS="raspberry"

header_start "Remove previous key"
jh-ssh-forget "$SSH_HOST"
header_done

header_start "Setup remote start..."
./setup-remote.sh "$SSH_HOST" "$SSH_USER" "$SSH_PASS" "kiosk"
header_done

header_start "Preparing setup"
header_start "Push files"
scp "$JH_SECRETS_FOLDER"/crypted/kiosk/synology.credentials "root@$SSH_HOST":/etc/jehon/restricted/
scp "$JH_SECRETS_FOLDER"/crypted/kiosk/kiosk.fstab "root@$SSH_HOST":/etc/jehon/
scp "usr/share/jehon/rasperry/lightdm-autostart.conf" /etc/jehon
header_done

header_start "Run scripts on setup"
# Possible groups: nopasswdlogin
ssh "root@$SSH_HOST" -T <<EOS
	echo "Add mount's"
	chmod 500 /etc/jehon/restricted/synology.credentials
	jh-patch-file /etc/jehon/kiosk.fstab
	mkdir -p /media/photo
	mkdir -p /media/exploits
	mount -a

	echo "Add user kiosk"
	useradd "kiosk" --create-home --groups "audio,video,plugdev,netdev,dip,cdrom"

	echo "* Allow personnal key to log in as kiosk"
	ln -s /etc/ssh/authorized_keys/jehon /etc/ssh/authorized_keys/kiosk

	echo "* Patching sshd the old way"
	jh-patch /usr/share/jehon/etc/ssh/sshd_config.d/jehon.conf

# echo "* Disabling pi user"
# passwd -l pi
EOS
header_done
header_done

header_start "Checkout"
ssh "kiosk@$SSH_HOST" -T <<EOS
	if [ -r kiosk ]; then
		cd kiosk && git pull
	else
		git clone https://github.com/jehon/kiosk.git
	fi
EOS
header_done

header_start "Install as root"
# rm -f /etc/systemd/system/default.target
# ln -s /lib/systemd/system/graphical.target /etc/systemd/system/default.target
ssh "root@$SSH_HOST" -T <<EOS
	jh-patch /etc/jehon/lightdm-autostart.conf

	kiosk/bin/kiosk-install-sudo.sh

	echo "Redirect sound output to jack first card"
	cp /usr/share/jehon/rasperry/asound.conf /etc/
	chmod 640 /etc/asound.conf
EOS
header_done

header_start "Install as user"
# echo "arch=armv7l" >.npmrc

ssh "kiosk@$SSH_HOST" -T <<EOS
	kiosk/bin/kiosk-install.sh
EOS
header_done

header_start "Starting the kiosk"
ssh "kiosk@$SSH_HOST" "kiosk/kiosk-start.sh"
header_done

#!/usr/bin/env bash

set -e

ssh-keygen -f "/home/jehon/.ssh/known_hosts" -R "kiosk"
ssh-keygen -f "/home/jehon/.ssh/known_hosts" -R "$(dig +short kiosk)"

jh-ping-ssh.sh kiosk

echo "*** setup remote start... ***"
./setup-remote.sh kiosk pi raspberry
echo "*** setup remote done ***"
echo "*** setup remote home start... ***"
./setup-remote-home.sh kiosk
echo "*** setup remote home done ***"

ssh root@kiosk -T << EOS
	cd /opt/
	wget https://raw.githubusercontent.com/jehon/kiosk/master/kickstart.sh -O /opt/kickstart.sh
	chmod +x /opt/kickstart.sh
	/opt/kickstart.sh && rm /opt/kickstart.sh
EOS

# TODO: copy fstab file from local repo

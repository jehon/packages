#!/usr/bin/env bash

./setup-remote.sh kiosk pi
./setup-remote-home.sh kiosk

ssh root@kiosk -T << EOS
	mkdir -p /opt/kiosk
	cd /opt/kiosk
	wget https://raw.githubusercontent.com/jehon/packages/master/start -O start
	chmod +x start
	./start
EOS

# TODO: copy fstab file from local repo

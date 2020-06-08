#!/usr/bin/env bash


for f in /etc/apt/sources.list.d/*.list; do 
	if grep -r "# deb" /etc/apt/sources.list.d -q ; then
		echo "Enabling back $f"
		sed -i 's/^# \(.*\)( # disabled on upgrade to.*)?/\1/g' "$f"
	fi
done

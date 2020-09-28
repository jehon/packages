#!/usr/bin/env bash

gspid=$(pgrep "gnome-session")
dbsavn="DBUS_SESSION_BUS_ADDRESS"
dbsadd=""
shortcutFile=""
istrusted=0

echo "Desktop icon configurations..."
if ! (( gspid )) ; then
	echo "GNOME session not found"
	exit 1
fi

dbsadd="$(grep -z "$dbsavn" "/proc/$gspid/environ")"
if [[ "$dbsadd" = "" ]]; then
	echo "environment variable '$dbsavn' not found"
	exit 1
fi

eval "export $dbsadd"

shortcutFile="$1"
istrusted=$(gio info "$shortcutFile" | awk '$1 == "metadata::trusted:" && $2 == "yes" {print 1 ; exit}')
if (( istrusted )) ; then
	echo "Icon already trusted  $shortcutFile"
	exit 0
fi

echo "Trusting $shortcutFile"
gio set "$shortcutFile" "metadata::trusted" "yes"

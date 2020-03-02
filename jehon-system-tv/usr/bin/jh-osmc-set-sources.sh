#!/usr/bin/env bash

# shellcheck disable=SC1091
. /etc/jehon/restricted/jehon.env

if [ -z "$SYNOLOGY_USERNAME" ]; then
    echo "Need a SYNOLOGY_USERNAME in /etc/jehon/restricted/jehon.env" >&2
    exit 255
fi

if [ -z "$SYNOLOGY_PASSWORD" ]; then
    echo "Need a SYNOLOGY_PASSWORD in /etc/jehon/restricted/jehon.env" >&2
    exit 255
fi

envsubst < ../lib/jehon/src/sources.xml > /home/osmc/.kodi/userdate/sources.xml

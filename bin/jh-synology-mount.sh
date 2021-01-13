#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
. jh-lib.sh

TARGET=~/synology/"$1"

mkdir -p "$TARGET"
sudo mount "//$JH_SYNOLOGY_IP/$1" "$TARGET" \
    -t cifs \
    -o vers=1.0,auto,user,noexec,nosuid,credentials=/home/jehon/src/bin/synology.credentials,iocharset=utf8,cache=strict
echo "Mounted $1 to $TARGET"

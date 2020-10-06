#!/usr/bin/env bash

# shellcheck source=/dev/null
. jh-lib.sh

set -e

EXE="/usr/bin/shuttle-go"
CFG="/usr/share/jehon-base-minimal/shuttle-go.json"

if [ -n "$PKG_FOLDER" ]; then
    EXE="$PKG_FOLDER/externals/shuttle-go/shuttle-go"
    CFG="$PKG_FOLDER/jehon-base-minimal/usr/share/jehon-base-minimal/shuttle-go.json"
fi

echo "EXE: $EXE"
echo "CFG: $CFG"

"$EXE" \
    -config "$CFG" \
    -debug

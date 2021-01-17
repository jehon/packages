#!/usr/bin/env bash

SELF_KEY="/usr/share/jehon/gpg.packages.pub.asc"
SELF_KEY_ID=$( gpg --show-keys --with-colons "$SELF_KEY" | grep "^pub" | cut -d : -f 5 )

jh-apt-add-key.sh "$SELF_KEY_ID" "Self-signed key" "$SELF_KEY"

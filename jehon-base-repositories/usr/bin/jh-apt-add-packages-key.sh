#!/usr/bin/env bash

SELF_KEY="/usr/share/jehon/gpg.packages.pub.asc"
SELF_KEY_ID=$( gpg --show-keys --with-colons "$SELF_KEY" | grep "^pub" | cut -d : -f 5 )

if ! hasKey "$SELF_KEY_ID" ; then
    echo "*** Adding self key $SELF_KEY_ID"
    apt-key add "$SELF_KEY"
fi

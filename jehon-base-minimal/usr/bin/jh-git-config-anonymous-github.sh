#!/usr/bin/env bash

if [ -n "$1" ]; then
    echo "Configuring globally"
    G="--global"
fi

git config $G user.email jehon@users.noreply.github.com

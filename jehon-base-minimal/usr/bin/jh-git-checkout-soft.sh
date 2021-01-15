#!/usr/bin/env bash

# TO BE TESTED

# Thanks to https://stackoverflow.com/a/11279083/1954789

if [ -z "$1" ]; then
    echo " [1]: Specify where to go: master ?" >&2
    exit 1
fi

git checkout --detach
git reset --soft "$1"
git checkout "$1"

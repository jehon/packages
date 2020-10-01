#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Need to specify a file as [1]"
    exit 255
fi

git update-index --chmod=+x "$1"
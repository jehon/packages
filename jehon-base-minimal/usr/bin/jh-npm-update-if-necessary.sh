#!/usr/bin/env bash

set -o errexit

if [ -n "$1" ]; then
	pushd "$1"
fi

if [ ! -r package.json ]; then
	echo "Could not find package.json in $(pwd): "
	ls
	exit 1
fi

if [ -r package-lock.json ] && [ package-lock.json -nt package.json ]; then
	echo "Already up-to-date"
	exit 0
fi

echo "Need an update"
echo "** install $1 **"
npm install

echo "** prune $1 **"
npm prune || true

echo "** done $1 **"
touch package-lock.json

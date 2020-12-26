#!/usr/bin/env bash

set -e

ORIGIN="$(git remote get-url origin)"
SLUG="$ORIGIN"
SLUG="${SLUG##git@github.com:}"
SLUG="${SLUG%.git}"
BRANCH="$(git name-rev --name-only HEAD)"

echo "Looking for"
echo "- slug: $SLUG"
echo "- branch: $BRANCH"

if wget  -O - "https://travis-ci.com/$SLUG.svg?branch=$BRANCH" 2>/dev/null | grep "#010101" > /dev/null ; then
    echo "Build ok"
    exit 0
else
    echo "Build ko"
    exit 1
fi

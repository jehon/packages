#!/usr/bin/env bash

set -e

. jh-lib.sh

ORIGIN="$(git remote get-url origin)"
SLUG="$ORIGIN"
SLUG="${SLUG##git@github.com:}"
SLUG="${SLUG%.git}"
BRANCH="$(git name-rev --name-only HEAD)"

echo "Looking for"
echo "- slug: $SLUG"
echo "- branch: $BRANCH"

# LOCAL COMMIT NOT PUSHED
AHEAD=$(git status --ahead-behind --porcelain)
if [ -n "$AHEAD" ]; then
    ok "Remote branch up-to-date"
else
    ko "Remote branch: $AHEAD"
fi

# STASH LIST
STASH_N=$(git stash list | wc -l)
if [[ $STASH_N -eq 0 ]] ; then
    ok "No stash found locally"
else
    ko "$STASH_N stash'es found locally"
fi

# TRAVIS LAST BUILD ON BRANCH STATUS

if wget  -O - "https://travis-ci.com/$SLUG.svg?branch=$BRANCH" 2>/dev/null | grep "#010101" > /dev/null ; then
    ok "Build ok"
    exit 0
else
    ko "Build ko"
    exit 1
fi

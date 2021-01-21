#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
. jh-lib.sh

ORIGIN="$(git remote get-url origin)"
GIT_SLUG="$ORIGIN"
GIT_SLUG="${GIT_SLUG##git@github.com:}"
GIT_SLUG="${GIT_SLUG%.git}"
GIT_OWNER="${GIT_SLUG/\/*}"
GIT_PROJECT="${GIT_SLUG#*\/}"
GIT_BRANCH="$(git name-rev --name-only HEAD)"

echo "Looking for"
echo "- GIT_SLUG:    $GIT_SLUG"
echo "- GIT_OWNER:   $GIT_OWNER"
echo "- GIT_PROJECT: $GIT_PROJECT"
echo "- GIT_BRANCH:  $GIT_BRANCH"
echo ""

# LOCAL COMMIT NOT PUSHED
AHEAD=$(git status -sb | grep -E '\[(ahead|behind)' | sed -r 's/^.*\[//g' | sed -r 's/\].*$//g' )
if [ -z "$AHEAD" ]; then
    ok "Remote origin up-to-date"
else
    ko "Remote origin: $AHEAD"
fi

# STASH LIST
GIT_STASH_CNT=$(git stash list | wc -l)
if [[ $GIT_STASH_CNT -eq 0 ]] ; then
    ok "No stash found locally"
else
    ko "$GIT_STASH_CNT stash'es found locally"
fi

export GIT_SLUG
export GIT_OWNER
export GIT_PROJECT
export GIT_BRANCH
export GIT_STASH_CNT

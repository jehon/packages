#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
. jh-lib.sh

PAD_HEADER=25

ORIGIN="$(git remote get-url origin)"
GIT_SLUG="$ORIGIN"
GIT_SLUG="${GIT_SLUG##git@github.com:}"
GIT_SLUG="${GIT_SLUG%.git}"
GIT_OWNER="${GIT_SLUG/\/*}"
GIT_PROJECT="${GIT_SLUG#*\/}"
GIT_BRANCH="$(git name-rev --name-only HEAD)"

m() {
    echo "$1 $(printf %-${PAD_HEADER}s "$2:") $3"
}

echo "Looking for"
m "-" "GIT_SLUG" "$GIT_SLUG"
m "-" "GIT_OWNER" "$GIT_OWNER"
m "-" "GIT_PROJECT" "$GIT_PROJECT"
m "-" "GIT_BRANCH" "$GIT_BRANCH"

export m
export PAD_HEADER
export GIT_SLUG
export GIT_OWNER
export GIT_PROJECT
export GIT_BRANCH
export GIT_STASH_CNT

# LOCAL COMMIT NOT PUSHED
AHEAD=$(git status -sb | grep -E '\[(ahead|behind)' | sed -r 's/^.*\[//g' | sed -r 's/\].*$//g' )
if [ -z "$AHEAD" ]; then
    m "$JH_MSG_OK" "GIT origin" "up-to-date"
else
    m "$JH_MSG_KO" "GIT origin" "$AHEAD"
fi

# STASH LIST
GIT_STASH_CNT=$(git stash list | wc -l)
if [[ $GIT_STASH_CNT -eq 0 ]] ; then
    m "$JH_MSG_OK" "GIT Stash" "None"
else
    m "$JH_MSG_KO" "GIT Stash" "$GIT_STASH_CNT"
fi

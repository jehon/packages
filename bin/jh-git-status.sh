#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
. jh-lib.sh

ORIGIN="$(git remote get-url origin)"
GIT_PROJECT_NAME="$ORIGIN"
GIT_PROJECT_NAME="${GIT_PROJECT_NAME##git@github.com:}"
GIT_PROJECT_NAME="${GIT_PROJECT_NAME%.git}"
GIT_BRANCH="$(git name-rev --name-only HEAD)"

echo "Looking for"
echo "- GIT_PROJECT_NAME: $GIT_PROJECT_NAME"
echo "- GIT_BRANCH:       $GIT_BRANCH"
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

export GIT_PROJECT_NAME
export GIT_BRANCH
export GIT_STASH_CNT

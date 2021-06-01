#!/usr/bin/env bash

set -o errexit

# shellcheck source=/dev/null
. jh-lib

# shellcheck source=/dev/null
. jh-git-status.sh

# TRAVIS LAST BUILD ON BRANCH STATUS

if wget -O - "https://travis-ci.com/$GIT_PROJECT_NAME.svg?branch=$GIT_BRANCH" 2>/dev/null | grep "#010101" >/dev/null; then
    ok "Build ok"
    exit 0
else
    ko "Build ko"
    exit 1
fi

#!/usr/bin/env bash

# shellcheck source=/dev/null
. jh-lib.sh

# git config --global --unset user.email
git config --global user.name "Jean Honlet"
git config --global push.default "simple"
git config --global push.default current
git config --global push.followtags true

# Convert crlf on input, checkout untouched Thanks to https://stackoverflow.com/a/20653073/1954789
git config --global core.autocrlf input

if [ -z "$1" ]; then
    echo "Set your email with: git config user.email jehon@users.noreply.github.com"
else
    /usr/bin/jh-git-config-anonymous-github.sh "global"
fi

echo "git commit -u - allow pushing everything"

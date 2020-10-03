#!/usr/bin/env bash

ROOT="$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )"
echo "ROOT: $ROOT"

# git config --global --unset user.email
git config --global user.name "Jean Honlet"
git config --global push.default "simple"
git config --global push.default current
git config --global push.followtags true
git config --global core.hooksPath "$ROOT/scripts/git"

# Convert crlf on input, checkout untouched Thanks to https://stackoverflow.com/a/20653073/1954789
git config --global core.autocrlf input

echo "Set your email with: git config user.email jehon@users.noreply.github.com"
echo "git commit -u - allow pushing everything"

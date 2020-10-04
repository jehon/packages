#!/usr/bin/env bash

# shellcheck source=/dev/null
. jh-lib.sh

# git config --global --unset user.email
git config --global user.name "Jean Honlet"
git config --global push.default "simple"
git config --global push.default current
git config --global push.followtags true
if [ -n "$PKG_FOLDER" ]; then
    git config --global core.hooksPath "$PKG_FOLDER/usr/share/$PKG_NAME/git"
else
    git config --global core.hooksPath "/usr/share/$PKG_NAME/git"
fi

# Convert crlf on input, checkout untouched Thanks to https://stackoverflow.com/a/20653073/1954789
git config --global core.autocrlf input

echo "Set your email with: git config user.email jehon@users.noreply.github.com"
echo "git commit -u - allow pushing everything"

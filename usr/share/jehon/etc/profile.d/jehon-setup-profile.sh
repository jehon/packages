#!/usr/bin/env sh

# For pip (python) local install
if [ -x ~/.local/bin ]; then
    export PATH=~/.local/bin/:"$PATH"
fi

if [ -n "$BASH_VERSION" ]; then

    # shellcheck source=/dev/null
    . /usr/bin/jehon-profile-bash.sh
fi

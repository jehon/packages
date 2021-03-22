#!/usr/bin/env bash

WSL_INTEROP="$( ls -t /run/WSL/*_interop | head -1 )"
DISPLAY="$(awk '/namespace/ { print $2":0" }' /etc/resolv.conf)"

if [ -f "$HOME/.wsl_env" ]; then
        set -a
        # shellcheck source=/dev/null
        source "$HOME/.wsl_env"
        set +a
fi

export WSL_INTEROP
export DISPLAY

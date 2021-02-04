#!/usr/bin/env bash

# For pip (python) local install
if [ -x /home/jehon/.local/bin ]; then
	export PATH=~/.local/bin/:"$PATH"
fi

# See https://unix.stackexchange.com/a/26782/240487
# interactive => if [[ $- == *i* ]]
# login       => if shopt -q login_shell

## SCREEN: autostart if .jhn-auto-screen ##

if [[ -r ".jhn-auto-screen" ]]; then
    if [[ -z "${STY}" ]]; then
        # We are not in screen
        if [[ $- == *i* ]] && [[ -n "${SSH_CLIENT}" ]]; then
            # But since we are on ssh, and interactive, we should be
            screen -RR -l
            exit $?
        fi
    fi
fi

## PROMPT ##

__parse_git_branch() {
    if ! git branch >/dev/null 2>&1; then
        return
    fi
    echo -n "("
    echo -n "$(basename "$(git rev-parse --show-toplevel)" )"
    echo -n ":"
    echo -n "$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
    if [[ -n $(git status -s) ]]; then
        echo -n "*"
    fi
    echo -n ")"
}

__cmd_result() {
    __LAST_RESULT="$?"
    case "$__LAST_RESULT" in
        0)
            echo -ne "\033[01;32m✓\033[00m"
            ;;
        130)
            # Ctrl-C
            echo -ne "\033[31m^C\033[00m"
            ;;
        *)
            echo -ne "\033[31m✗\033[00m"
            ;;
    esac

  # shellcheck disable=2154 # (no undeclared variables)
    PS1+="${RCol}@${BBlu}\h ${Pur}\W${BYel}$ ${RCol}"
}

if [[ "$( id -u )" != "0" ]]; then
    # Only if not root

    # Start with a white line
    PS1=''
    # last command result / git status / screen id
    # !! enclose escape in \[xxx\] to avoid wrapping problems
    PS1=$PS1'\n$(__cmd_result) \[\033\][33m$(__parse_git_branch)\[\033\][\[00m\] ${STY:+(screen) }'

    # user@host / folder
    PS1=$PS1'\n${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;37m\]\w\[\033[00m\] \$ '
    export PS1
    export debian_chroot

    # Already calculated:
    if [ -z "$UID" ]; then
        UID=$(id -u)
    fi
    if [ -z "$GID" ]; then
        GID=$(id -g)
    fi

    export UID
    export GID
fi

if [ -x thefuck ]; then
    eval "$(thefuck --alias)"
    alias z="fuck"
fi

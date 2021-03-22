#!/bin/sh

#
# https://snapcraft.ninja/2020/08/06/starting-systemd-in-wsl-when-you-login-to-windows-youll-be-astounded-by-the-speed-improvement/
#

ME="$0"
SHELL="$(echo "$0" | sed -e 's/namespaced-//')"
if [ "$1" = "-c" ]; then
        # this is for VSCode support
        shift
        SAVE_CMD="$@"
        if echo "$1" | grep -q '^sh -c'; then
                SAVE_CMD_NOSH="$(echo "$1" | sed -e 's/^sh -c//')"
                SAVE_CMD="$(eval echo "$SAVE_CMD_NOSH")"
                shift
        fi
        eval echo "$SAVE_CMD" > "$HOME/.wsl_cmd"
fi

if [ "$USER" != "root" ]; then
        export > "$HOME/.wsl_env"
        exec sudo "$ME"
fi

SYSTEMD_PID="$(ps -eo pid=,args= | awk '$2" "$3=="systemd --unit=multi-user.target" { print $1 }')"
if [ -z "$SYSTEMD_PID" ]; then
        /usr/bin/daemonize /usr/bin/unshare --fork --mount-proc --pid -- /bin/sh -c "mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc; exec systemd --unit=multi-user.target"
        while [ -z "$SYSTEMD_PID" ]; do
                sleep 1
                SYSTEMD_PID="$(ps -eo pid=,args= | awk '$2" "$3=="systemd --unit=multi-user.target" { print $1 }')"
        done
        sleep 1
fi

CMD_FILE="$(eval echo "~$SUDO_USER/.wsl_cmd")"
if [ -f "$CMD_FILE" ]; then
        trap "rm -f '$CMD_FILE'" EXIT
        nsenter -a -t "$SYSTEMD_PID" sudo -u "$SUDO_USER" "$SHELL" -c "$CMD"
else
        exec nsenter -a -t "$SYSTEMD_PID" su --pty --shell="$SHELL" --login "$SUDO_USER"
fi
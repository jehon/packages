#!/usr/bin/env bash

# echo "Should run as: $HOST_UID : $HOST_GID"

GN=$( grep ":$HOST_GID:" /etc/group | cut -d ":" -f 1 )
if [ -z "$GN" ]; then
	GN="host_group"
	groupadd $GN -g "$HOST_GID"
fi

if ! id -u "$HOST_UID" >/dev/null 2>/dev/null ; then
	UN="host_user"
	adduser --system --uid "$HOST_UID" --gid "$HOST_GID" $UN
else
	UN="$(id -un "$HOST_UID")"
fi

# Allow user to be sudoers
if ! grep "$UN" /etc/sudoers ; then
	echo "$UN    ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
fi

# echo "Going with user $UN and group $GN"
# echo "Running in bash: '$*'"

runuser -u "$UN" -- bash -c "$*"

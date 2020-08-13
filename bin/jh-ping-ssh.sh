#!/usr/bin/env bash

TARGET_HOST="$1"

echo "=== Pinging host ==="
if ! ping -w 1 -c 1 "$TARGET_HOST" ; then
  echo "ICMP ping: '$TARGET_HOST' is not reachable" >&2
  exit 2
fi

echo "=== Trying to open an ssh connection ==="
status=$( \
    ssh \
        -o BatchMode=yes \
        -o CheckHostIP=no \
        -o StrictHostKeyChecking=no \
        -o HashKnownHosts=no \
        -o ConnectTimeout=10 \
        $TARGET_HOST echo pong 2>&1 | grep -oE 'pong|denied|sftp' \
)

if [[ $status != pong && $status != denied && $status != sftp ]]; then
  echo "SSH ping: failed with status: $status"
  exit 2
fi

exit 0

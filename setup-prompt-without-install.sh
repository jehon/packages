#!/usr/bin/env bash

ROOT="$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )"
SRC="$ROOT/.."

# shellcheck source=/dev/null
. "$ROOT"/jehon-base-minimal/etc/profile.d/jehon_direct_access.sh

echo "Looking for custom bash"
for F in $( find "$SRC" -mount -type f -name "custom-bash.sh" ); do
    echo "Importing $F"
    # . "$F"
done

#!/usr/bin/env bash

set -e

ROOT="$( realpath "$( dirname "$( dirname "${BASH_SOURCE[0]}" )" )" )"
SRC="$ROOT/.."

# shellcheck source=/dev/null
. "$ROOT"/jehon-base-minimal/etc/profile.d/jehon_custom.sh

export PATH="$ROOT/bin:$PATH"

echo "Looking for custom profile"
while read F ; do
	echo "Importing $F"
	. "$F"
done < <( find "$SRC" -name "custom-profile.sh" )

CDPATH=".:$(realpath "$SRC")"

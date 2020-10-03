#!/usr/bin/env bash

# set -e

ROOT="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"
echo "$ROOT"
SRC="$ROOT/.."

# shellcheck source=/dev/null
. "$ROOT"/jehon-base-minimal/usr/share/jehon-base-minimal/jehon-custom.sh

export PATH="$ROOT/bin:$PATH"

echo "Looking for custom profile in $SRC"
while read F ; do
	echo "Importing $F"
	source "$F"
done < <( find "$SRC" -type d \
	\( -name "node_modules" -o -name "vendor" -o -name "tmp" \) \
	-prune -false \
	-o -name "custom-profile.sh" )

CDPATH=".:$(realpath "$SRC")"


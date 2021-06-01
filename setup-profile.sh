#!/usr/bin/env bash

# set -o errexit

# We need to calculate it us-self to be able to import jh-lib
JH_SWD="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"

#
# Will define JH_PKG_FOLDER
#
# shellcheck source=/dev/null
. "$JH_SWD/jehon-base-minimal/usr/bin/jh-lib"

#
# Look for the files locally
#
export PATH="$JH_PKG_FOLDER/bin:$JH_PKG_FOLDER/$JH_PKG_MINIMAL_NAME/usr/bin:$PATH"

SRC="$(realpath "$JH_PKG_FOLDER/..")"

# shellcheck source=/dev/null
. "$JH_PKG_FOLDER/$JH_PKG_MINIMAL_NAME/usr/share/$JH_PKG_MINIMAL_NAME/etc/profile.d/jehon-custom.sh"

header "** Looking for custom profile in $SRC"
while read F; do
	echo "Importing $F"
	# shellcheck source=/dev/null
	source "$F"
done < <(find "$SRC" -type d \
	\( -name "node_modules" -o -name "vendor" -o -name "tmp" \) \
	-prune -false \
	-o -name "custom-profile.sh")

EBIN="$(realpath "$JH_SWD/../bin")"
if [ -d "$EBIN" ]; then
	header "** Adding $EBIN"
	export PATH="$EBIN:$PATH"
fi

header "** Configure CDPATH **"
CDPATH=".:$SRC"

export JH_PKG_FOLDER

#!/usr/bin/env bash

# set -e

# We need to calculate it us-self to be able to import jh-lib.sh
JH_SWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

#
# Will define JH_PKG_FOLDER
#
# shellcheck source=/dev/null
. "$JH_SWD/jehon-base-minimal/usr/bin/jh-lib.sh"

#
# Look for the files locally
#
export PATH="$JH_PKG_FOLDER/bin:$JH_PKG_FOLDER/$JH_PKG_MINIMAL_NAME/usr/bin:$PATH"

SRC="$( realpath "$JH_PKG_FOLDER/.." )"

# shellcheck source=/dev/null
. "$JH_PKG_FOLDER/$JH_PKG_MINIMAL_NAME/usr/share/$JH_PKG_MINIMAL_NAME/etc/profile.d/jehon-custom.sh"

header "** Looking for custom profile in $SRC"
while read F ; do
	echo "Importing $F"
	source "$F"
done < <( find "$SRC" -type d \
	\( -name "node_modules" -o -name "vendor" -o -name "tmp" \) \
	-prune -false \
	-o -name "custom-profile.sh" )

EBIN="$( realpath "$SWD/../bin" )"
if [ -d "$EBIN" ]; then
	header "** Adding $EBIN"
	export PATH="$EBIN:$PATH"
fi

header "** Configure CDPATH **"
CDPATH=".:$SRC"

header "** Configure APT **"
FILE="/etc/apt/sources.list.d/jehon-package-repo.list"

LINE="deb [trusted=yes] file://$JH_PKG_FOLDER/repo /"
ORIGINAL="$( cat "$FILE" )"

if [ "$ORIGINAL" != "$LINE" ]; then
    warning "!! Need to update $FILE (as root) !!"
    echo "original :  $ORIGINAL" >&2
    echo "should be: $LINE" >&2
	echo "--- Do that as root ---"
	if [ -w /etc/apt/sources.list.d/jehon-package-repo.list ]; then
    	echo "$LINE" | sudo tee /etc/apt/sources.list.d/jehon-package-repo.list
	else
		echo "$LINE" > ~/jehon-package-repo.list
		echo "Copy it to target:"
		echo "sudo cp jehon-package-repo.list /etc/apt/sources.list.d"
	fi
fi

export JH_PKG_FOLDER

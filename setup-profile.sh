#!/usr/bin/env bash

# set -e

# We need to calculate it us-self to be able to import jh-lib.sh
SWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

# shellcheck source=/dev/null
. "$SWD/jehon-base-minimal/usr/bin/jh-lib.sh"

SRC="$( realpath "$PKG_FOLDER/.." )"

# shellcheck source=/dev/null
. "$PKG_FOLDER/$PKG_NAME/usr/share/$PKG_NAME/etc/jehon-custom.sh"

export PATH="$PKG_FOLDER/bin:$PKG_FOLDER/$PKG_NAME/usr/bin:$PATH"

header "** Looking for custom profile in $SRC"
while read F ; do
	echo "Importing $F"
	source "$F"
done < <( find "$SRC" -type d \
	\( -name "node_modules" -o -name "vendor" -o -name "tmp" \) \
	-prune -false \
	-o -name "custom-profile.sh" )

header "** Configure CDPATH **"
CDPATH=".:$SRC"

header "** Configure APT **"
FILE="/etc/apt/sources.list.d/jehon-package-repo.list"

LINE="deb [trusted=yes] file://$PKG_FOLDER/repo /"
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

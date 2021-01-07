#!/usr/bin/env bash

set -e

SWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

#
#
# Sources list files
#
#

echo "*** Copying sources.list files"
SD="/etc/apt/sources.list.d/"
for F in "$SWD"/../share/jehon-base-repositories/*.list ; do
    N="$(basename "$F" )"
    if ! diff -q "$F" "$SD" > /dev/null ; then
        echo "*** Repository $N"
        cp "$F" "$SD"
    fi
done
echo "*** Generating sources.list files"
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > "$SD/docker.list"


#
#
# Keys
#
#

hasKey() {
    gpg --keyring /etc/apt/trusted.gpg --no-default-keyring --list-key "$1" >/dev/null
    # 2>/dev/null
}

hasKeyOrImport() {
    if ! hasKey "$1" ; then
        echo "*** Key $2 ($1) does not exists, importing it..."
        apt-key adv --recv-keys --keyserver keyserver.ubuntu.com "$1"
    fi
}

hasKeyOrImport "1397BC53640DB551" "Chrome (ubuntu)"
hasKeyOrImport "78BD65473CB3BD13" "Chrome (raspberrypi)"
hasKeyOrImport "1655A0AB68576280" "nodejs"
hasKeyOrImport "FCEF32E745F2C3D5" "jenkins"
hasKeyOrImport "7EA0A9C3F273FCD8" "Docker"

"$SWD"/jh-apt-add-packages-key.sh

echo "*** Done"
#!/usr/bin/env bash

set -e

SWD="$( realpath "$( dirname "${BASH_SOURCE[0]}" )" )"

#
#
# Sources list files
#
#
SD="/etc/apt/sources.list.d/"

echo "*** Generating sources.list files"
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > "$SD/docker.list"


#
#
# Keys
#
#

jh-apt-add-key.sh "1397BC53640DB551" "Chrome (ubuntu)"
jh-apt-add-key.sh "78BD65473CB3BD13" "Chrome (raspberrypi)"
jh-apt-add-key.sh "1655A0AB68576280" "nodejs"
jh-apt-add-key.sh "FCEF32E745F2C3D5" "jenkins"
jh-apt-add-key.sh "7EA0A9C3F273FCD8" "Docker"

"$SWD"/jh-apt-add-packages-key.sh

echo "*** Done"

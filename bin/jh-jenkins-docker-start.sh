#!/usr/bin/env bash

set -e

# shellcheck source=../jehon-base-minimal/usr/bin/jh-lib.sh
. jh-lib.sh

# See https://www.jenkins.io/doc/book/installing/docker/

echo "********* Starting SSH on host...   ******************"
sudo service ssh start
echo "********* Starting SSH on host done ******************"

WEB=8080
REVERSE_IP="$(jh-ip-list | grep 172 | cut -f 2 -d ' ')"

pushd "$JH_PKG_FOLDER" > /dev/null

if [ "$1" = "-f" ]; then
    rm -fr dockers/jenkins/shared/generated
    ( docker stop jenkins || true )  &> /dev/null
    ( docker rm -f jenkins || true ) &> /dev/null
    ( docker image rm -f jehon/jenkins || true ) &> /dev/null
    rm -f dockers/jenkins/.dockerbuild
fi

make dockers/jenkins/.dockerbuild

ssh-keygen -f "/home/jehon/.ssh/known_hosts" -R "[localhost]:2022"

cat <<EOT

*****************************************
*
* Ports:
*      web interface:  $WEB
*      reverse ip:     $REVERSE_IP
*      sshd server:    2022
*
*
* Run jenkins console:
*      ssh admin@localhost -p 2022 help
*
* Log into container:
*      docker exec -it jenkins bash
*****************************************

EOT

docker run --restart unless-stopped --name jenkins \
    -p $WEB:8080 \
    -p 2022:22 \
    --detach \
    jehon/jenkins

docker logs --follow jenkins

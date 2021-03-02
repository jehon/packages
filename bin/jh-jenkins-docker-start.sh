#!/usr/bin/env bash

set -e

# shellcheck source=../jehon-base-minimal/usr/bin/jh-lib.sh
. jh-lib.sh

# See https://www.jenkins.io/doc/book/installing/docker/

WEB=8080

# docker run --name jenkins-docker --rm --detach ^
#   --privileged ^
#   --env DOCKER_TLS_CERTDIR=/certs ^
#   --volume jenkins-docker-certs:/certs/client ^
#   --volume jenkins-data:/var/jenkins_home ^
#   docker:dind

if [ "$1" = "-f" ]; then
    echo "PKG_FOLDER: $PKG_FOLDER"
    pushd "$PKG_FOLDER" > /dev/null

    rm -fr dockers/jenkins/shared/generated
    docker stop jenkins || true > /dev/null
    docker rm -f jenkins || true > /dev/null
fi

make dockers/jenkins

ssh-keygen -f "/home/jehon/.ssh/known_hosts" -R "[localhost]:2022"

cat <<EOT

*****************************************
*
* Ports:
*      web interface:  $WEB
*      sshd server:    2022
*
* Run jenkins console:
*      ssh admin@localhost -p 2022 help
*
* Log into container:
*      docker exec -it jenkins bash
*****************************************

EOT

docker run --name jenkins -p $WEB:8080 -p 2022:22 jehon/jenkins

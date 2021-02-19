#!/usr/bin/env bash

set -e

# See https://www.jenkins.io/doc/book/installing/docker/

# docker run --name jenkins-docker --rm --detach ^
#   --privileged ^
#   --env DOCKER_TLS_CERTDIR=/certs ^
#   --volume jenkins-docker-certs:/certs/client ^
#   --volume jenkins-data:/var/jenkins_home ^
#   docker:dind

docker stop jenkins || true
docker rm -f jenkins

make dockers/jenkins

docker run --name jenkins -p 18080:8080 jehon/jenkins "$@"

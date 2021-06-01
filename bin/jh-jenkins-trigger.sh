#!/usr/bin/env bash

set -o errexit
# shellcheck source=/dev/null
. jh-jenkins-status.sh

echo "BRANCH: $GIT_BRANCH"

echo "Launching build..."
ssh "${JENKINS_HOST}" -p "${JENKINS_SSH}" build "github/${GIT_PROJECT}/${GIT_BRANCH}"
# curl --fail -X POST "$JENKINS_URL_JOB/build?delay=0sec"
echo "Launching build... done"

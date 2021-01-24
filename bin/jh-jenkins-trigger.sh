#!/usr/bin/env bash

set -e
# shellcheck source=/dev/null
. jh-jenkins-status.sh

if [ -n "$1" ]; then
    if [ "$1" == "all" ]; then
        echo "Building all"
    	curl --fail -X POST "$JENKINS_URL_PROJECT/build?delay=0sec"
        exit $?
    fi
fi

echo "BRANCH: $BRANCH"

echo "Launching build..."
curl --fail -X POST "$JENKINS_URL_JOB/build?delay=0sec"
echo "Launching build... done"

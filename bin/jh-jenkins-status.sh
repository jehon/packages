#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
. jh-lib.sh

# shellcheck source=/dev/null
. jh-git-status.sh || true

JENKINS_URL_PROJECT="http://$JENKINS_TOKEN@$JENKINS_HOST/job/${GIT_PROJECT}"
JENKINS_URL_JOB="$JENKINS_URL_PROJECT/job/${GIT_BRANCH//\//%2F}"

# curl http://jenkins.myserver.com/jenkins/job/utilities/job/my_job/8/api/json
# lastBuild/api/json
BUILD_DATA=$( curl --fail --silent -X POST "$JENKINS_URL_JOB/lastBuild/api/json" )

JOB_BUILDING="$(  echo "$BUILD_DATA" | jq -r ".building" )"
JOB_RESULT="$(    echo "$BUILD_DATA" | jq -r ".result" )"
JOB_TS="$(        echo "$BUILD_DATA" | jq -r ".timestamp" )"
JOB_NEXTBUILD="$( echo "$BUILD_DATA" | jq -r ".nextBuild" )"

# Jenkins use milliseconds, Unix seconds
(( JOB_TS = JOB_TS / 1000 ))
JOB_TS="$( date -d "@$JOB_TS" "+%y-%m-%d %T" )"

# echo "$BUILD_DATA" | jq "."

ok_ko "$JOB_NEXTBUILD" "null"    "JOB_NEXTBUILD:  $JOB_NEXTBUILD"
ok_ko "$JOB_BUILDING"  "false"   "JOB_BUILDING:   $JOB_BUILDING"
ok_ko "$JOB_RESULT"    "SUCCESS" "JOB_RESULT:     $JOB_RESULT"
echo "  JOB_TS:         $JOB_TS"

export JENKINS_URL_PROJECT
export JENKINS_URL_JOB

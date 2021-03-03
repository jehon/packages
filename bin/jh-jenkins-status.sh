#!/usr/bin/env bash

set -e

# shellcheck source=/dev/null
. jh-lib.sh

# shellcheck source=/dev/null
. jh-git-status.sh || true

JENKINS_URL_PROJECT="http://$JENKINS_HOST:$JENKINS_PORT/job/github/job/${GIT_PROJECT}"
JENKINS_URL_JOB="$JENKINS_URL_PROJECT/job/${GIT_BRANCH//\//%2F}"

# Reference:
#  https://www.jenkins.io/doc/book/managing/script-console/

# Get list of jobs:
#   https://javadoc.jenkins.io/hudson/model/AbstractItem.html -> getFullName()
#   https://javadoc.jenkins.io/plugin/workflow-job/org/jenkinsci/plugins/workflow/job/WorkflowJob.html
#     lastBuild: https://javadoc.jenkins.io/plugin/workflow-job/org/jenkinsci/plugins/workflow/job/WorkflowRun.html
#        getPreviousCompletedBuild()
#
GROOVY=$(cat <<-EOG
    import hudson.model.Job

    def m(ok_ko, header, result, resultok = '', resultko = '') {
        print ok_ko ? "ok " : "ko "
        print "JENKINS".concat(header ? " ".concat(header) : "").concat(":").padRight(${PAD_HEADER})
        print " "
        print result
        print (ok_ko ? resultok : resultko)
        println ""
    }

    jenkins.model.Jenkins.instance.getAllItems(Job)
        .find{job -> job.getFullName() == 'github/${GIT_PROJECT}/${GIT_BRANCH}'} // Comment out to have all names
        .each{
            // println(it.lastBuild)
            m(it.lastBuild.result.toString() == "SUCCESS", "last build", it.lastBuild.result)
            m(!it.lastBuild.building, '', '', 'idle', 'running')
            m(it.lastBuild.nextBuild == null, 'Next build', '', 'No', it.lastBuild.nextBuild)

            println("- ".concat("last build:".padRight(${PAD_HEADER})).concat(" ").concat(it.lastBuild.getTimestampString()))
        }
EOG
)

echo "$GROOVY" | ssh "${JENKINS_HOST}" -p "${JENKINS_SSH}" groovy "=" | parse_ok_ko

# JENKINS_URL_PROJECT="http://$JENKINS_HOST:$JENKINS_PORT/job/github/job/${GIT_PROJECT}"
# JENKINS_URL_JOB="$JENKINS_URL_PROJECT/job/${GIT_BRANCH//\//%2F}"
# # curl http://jenkins.myserver.com/jenkins/job/utilities/job/my_job/8/api/json
# # lastBuild/api/json
# BUILD_DATA=$( curl --fail --silent -X POST "$JENKINS_URL_JOB/lastBuild/api/json" )

# JOB_BUILDING="$(  echo "$BUILD_DATA" | jq -r ".building" )"
# JOB_RESULT="$(    echo "$BUILD_DATA" | jq -r ".result" )"
# JOB_TS="$(        echo "$BUILD_DATA" | jq -r ".timestamp" )"
# JOB_NEXTBUILD="$( echo "$BUILD_DATA" | jq -r ".nextBuild" )"

# # Jenkins use milliseconds, Unix seconds
# (( JOB_TS = JOB_TS / 1000 ))
# JOB_TS="$( date -d "@$JOB_TS" "+%y-%m-%d %T" )"

# # echo "$BUILD_DATA" | jq "."

# ok_ko "$JOB_NEXTBUILD" "null"    "JOB_NEXTBUILD:  $JOB_NEXTBUILD"
# ok_ko "$JOB_BUILDING"  "false"   "JOB_BUILDING:   $JOB_BUILDING"
# ok_ko "$JOB_RESULT"    "SUCCESS" "JOB_RESULT:     $JOB_RESULT"
# echo "  JOB_TS:         $JOB_TS"

export JENKINS_URL_PROJECT
export JENKINS_URL_JOB

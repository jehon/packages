
# Documentation: https://github.com/jenkinsci/docker/blob/master/README.md

FROM jenkins/jenkins:lts

ENV JHOME="/var/jenkins_home"
ENV LANG C.UTF-8

ENV CASC_JENKINS_CONFIG="/conf/jenkins.yml"

# See https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/docs/features/secrets.adoc
# ENV SECRETS="/conf/generated/"
ENV SECRETS_FILE=/conf/generated/secrets.properties

COPY --chown=jenkins:jenkins shared/ /conf/

RUN jenkins-plugin-cli --plugins \
    configuration-as-code \
    job-dsl \
    ssh-slaves \
    \
    ansicolor \
    blueocean \
    lockable-resources \
    pipeline-github \
    ssh-agent \
    ws-cleanup

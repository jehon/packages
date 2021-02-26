FROM jenkins/jenkins:lts

ENV JHOME="/var/jenkins_home"
ENV CASC_JENKINS_CONFIG="/conf/generated/jenkins.yml"
ENV LANG C.UTF-8

# Documentation: https://github.com/jenkinsci/docker/blob/master/README.md

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY --chown=jenkins:jenkins shared/ /conf/

RUN jenkins-plugin-cli --plugins \
    configuration-as-code \
    job-dsl \
    \
    ansicolor \
    blueocean \
    lockable-resources \
    pipeline-github \
    ssh-agent \
    ws-cleanup
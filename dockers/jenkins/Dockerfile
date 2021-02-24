FROM jenkins/jenkins:lts

ENV JHOME="/var/jenkins_home"
ENV LANG C.UTF-8
# RUN echo "Europe/Brussels" > /etc/timezone

# Documentation: https://github.com/jenkinsci/docker/blob/master/README.md

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Thanks to https://github.com/jenkinsci/docker/issues/310#issuecomment-692037293
COPY customize.groovy /usr/share/jenkins/ref/init.groovy.d/customize.groovy
COPY shared/ /conf/

RUN jenkins-plugin-cli --plugins \
    ansicolor \
    blueocean \
    lockable-resources \
    pipeline-github \
    ssh-agent \
    ws-cleanup

#!/usr/bin/env bash

# NOT TESTED

mkdir -p /var/backups/jenkins
chown -R jenkins /var/backups/jenkins

usermod -a -G docker jenkins

ufw allow 8080

#
# Change home to be in /home/jenkins
#   for snaps
#   thanks to https://dzone.com/articles/jenkins-02-changing-home-directory
#

cp /etc/default/jenkins /etc/default/jenkins.bak
sed -i "s/JENKINS_HOME=.*/JENKINS_HOME=\/home\/jenkins/" /etc/default/jenkins
if [ -d /var/lib/jenkins ] ; then
    mv /var/lib/jenkins /home
else
    mkdir /home/jenkins
    chown jenkins /home/jenkins
fi
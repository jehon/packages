#!/usr/bin/env bash

# NOT TESTED

# Backups
mkdir -p /var/backups/jenkins
chown -R jenkins /var/backups/jenkins

# Allow agents to run docker
usermod -a -G docker jenkins

# Allow http access
ufw allow Jenkins

#
# Change home to be in /home/jenkins
#   for snaps
#   thanks to https://dzone.com/articles/jenkins-02-changing-home-directory
#
cp /etc/default/jenkins /etc/default/jenkins.bak
sed -i "s/JENKINS_HOME=.*/JENKINS_HOME=\/home\/jenkins/" /etc/default/jenkins

if [ -d /var/lib/jenkins ] ; then
    mv /var/lib/jenkins /home
fi

mkdir -p /home/jenkins
chown jenkins /home/jenkins

# End



# upload ssh key: https://gist.github.com/hayderimran7/d6ab8a6a770cb970349e
# https://nickcharlton.net/posts/setting-jenkins-credentials-with-groovy.html
# https://www.devopsschool.com/blog/complete-guide-to-use-jenkins-cli-command-line/
# https://stackoverflow.com/questions/59396223/create-jenkins-ssh-username-with-private-key-credential-via-rest-xml-api

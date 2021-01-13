#!/usr/bin/env bash

# NOT TESTED

mkdir -p /var/backups/jenkins
chown -R jenkins /var/backups/jenkins

usermod -a -G docker jenkins

ufw allow 8080

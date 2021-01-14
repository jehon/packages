pipeline {
  agent any
  options {
    skipStagesAfterUnstable()
  }
  environment {
    PACKAGES_GPG_FILE = credentials('packages-gpg-key')
  }
  stages {
    stage('setup') {
      steps {
        sh 'gpg --import $PACKAGES_GPG_FILE'
        sh 'make all-setup'
      }
    }
    stage('dump') {
      steps {
        sh 'make all-dump'
      }
    }
    stage('build') {
      steps {
        sh 'make all-build'
      }
    }
    stage('sign') {
      steps {
        sh 'make repo/Release.gpg'
      }
    }
    stage('test') {
      steps {
        sh 'make all-test'
      }
    }
    stage('lint') {
      steps {
        sh 'make all-lint'
      }
    }
    stage('Deploy') {
      // when {
      //   branch 'master'
      // }
      steps {
        lock('packages_deploy') {
          sshagent(['jehon-nsi-wsl2-2020-PC1496']) {
              sh 'GIT_ORIGIN=gitorigin make --debug deploy-github'
          }
          // withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
        }
      }
    }
  }
  post {
    always {
      sh 'ls -l repo/'
      sh 'md5sum repo/*'
      sh 'make all-stop'
      deleteDir() /* clean up our workspace */
    }
  }
}
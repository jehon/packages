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
          sh 'make --debug deploy-github'
        }
      }
    }
  }
  post {
    always {
      sh 'ls -l repo/'
      sh 'md5sum repo/*'
      sh 'make stop'
      deleteDir() /* clean up our workspace */
    }
  }
}
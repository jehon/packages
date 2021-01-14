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
        sh 'git config user.name "$( git --no-pager show -s --format="%an" )"'
        sh 'git config user.email "$( git --no-pager show -s --format="%ae" )"'
        sh 'git config user.name'
        sh 'git config user.email'
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
          sh 'make --debug deploy-github'
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
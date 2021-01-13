pipeline {
  agent any
  options {
    skipStagesAfterUnstable()
  }
  stages {
    stage('setup') {
      steps {
        // sh ''
        // sh 'gpg --import secrets/gpg.packages.asc'
        sh 'make dockers/jehon-docker-build.dockerbuild'
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
    // stage('sign') {
    //   steps {
    //     sh 'make repo/Release.gpg'
    //   }
    // }
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
      options {
        lock resource: 'packages_deploy'
      }
      when {
        branch 'master'
      }
      steps {
        sh 'make deploy-github'
      }
    }
  }
  post {
    always {
      // sh 'make stop'
      // deleteDir() /* clean up our workspace */
    }
  }
}
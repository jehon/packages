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
        // https://stackoverflow.com/a/53326235/1954789
        // sh('git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/my-org/my-repo.git')
        // lock('packages_deploy') {
          // sh 'mkdir ~/.ssh'
          // sh 'echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > ~/.ssh/known_hosts'
          // See username on top right -> credentials
          // https://stackoverflow.com/a/44369176/1954789
          sshagent(credentials: ['jehon-nsi-wsl2-2020-PC1496']) {
              sh 'GIT_ORIGIN=gitorigin make --debug deploy-github'
          }
          // withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
          //   sh 'echo $GIT_USERNAME[0]'
          //   // sh 'make --debug deploy-github'
          // }
        // }
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
pipeline {
  agent any
  options {
    ansiColor('xterm')
    skipStagesAfterUnstable()
  }
  environment {
    GIT_CRYPT_KEY = credentials('git-crypt-key')
  }
  stages {
    stage('setup') {
      steps {
        sh 'md5sum $GIT_CRYPT_KEY'
        sh 'git-crypt unlock $GIT_CRYPT_KEY'
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
      when {
        branch 'master'
      }
      environment {
        // Transform the http url into ssh url
        GIT_URL_SSH = """${sh(
            returnStdout: true,
            script: 'echo "$GIT_URL" | sed "s#https://#ssh://git@#g" '
        )}"""
      }

      steps {
        lock('packages_deploy') {

          // Add key to known hosts to avoid problems when pushing
          sh 'mkdir -p ~/.ssh'
          sh 'echo "github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" > ~/.ssh/known_hosts'

          // Configure separated origin because the original one is in https
          sh 'git remote add sshorigin "${GIT_URL_SSH}" || git remote set-url sshorigin "${GIT_URL_SSH}"'

          // See username on top right -> credentials
          // Thanks to https://stackoverflow.com/a/44369176/1954789
          sshagent(credentials: ['github-ssh']) {
            // GIT_URL, GIT_USERNAME, GIT_PASSWORD => withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
            // sh 'echo "****** GIT_URL_SSH: $GIT_URL_SSH ******"'
            // sh 'git remote -v'

            sh 'GIT_ORIGIN=sshorigin make deploy-github'
          }
        }
      }
    }
  }
  post {
    always {
      sh 'make all-stop'
      deleteDir() /* clean up our workspace */
    }
  }
}
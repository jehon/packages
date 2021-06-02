pipeline {
  agent any
  options {
    ansiColor('xterm')
    skipStagesAfterUnstable()
    disableConcurrentBuilds()
    timeout(time: 15, unit: 'MINUTES')
  }
  environment {
    MAKEOPT = "--debug=basic"
    SECRETS_PASSWORD = credentials('secrets-password')
    SECRETS = "tmp/secrets"
  }
  stages {
    stage('clean up') {
      steps {
        sh 'rm -fr tmp/'
      }
    }
    stage('all-setup') {
      steps {
        sshagent(credentials: ['jenkins-github-ssh']) {
          sh 'mkdir -p "${SECRETS}"'
          sh 'git clone git@github.com:jehon/secrets.git tmp/secrets'
          sh '${SECRETS}/start ${SECRETS_PASSWORD}'
        }
        sh 'make ${MAKEOPT} ${STAGE_NAME}'
      }
    }
    stage('all-dump') {
      steps {
        sh 'make ${MAKEOPT} ${STAGE_NAME}'
      }
    }
    stage('all-build') {
      steps {
        sh 'make ${MAKEOPT} ${STAGE_NAME}'
      }
    }
    stage('packages-sign') {
      steps {
        sh 'make --debug ${STAGE_NAME}'
      }
    }
    stage('all-test') {
      steps {
        sh 'make ${MAKEOPT} ${STAGE_NAME}'
      }
    }
    stage('all-lint') {
      steps {
        sh 'make ${MAKEOPT} ${STAGE_NAME}'
      }
    }
    stage('Deploy') {
      when {
        branch 'main'
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
          sshagent(credentials: ['jenkins-github-ssh']) {
            // GIT_URL, GIT_USERNAME, GIT_PASSWORD => withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
            // sh 'echo "****** GIT_URL_SSH: $GIT_URL_SSH ******"'
            // sh 'git remote -v'

            sh 'GIT_ORIGIN=sshorigin make ${MAKEOPT} deploy-github'
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
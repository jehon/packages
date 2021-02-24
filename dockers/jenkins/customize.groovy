#!groovy

import jenkins.model.*
import hudson.security.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.CredentialsScope
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*

def instance = Jenkins.getInstance()

//
// Documentation
//
//   Great one: @nigimaster https://gist.github.com/nigimaster/6a014c62b444fe7a7744304d66881451
//

def getConfFileContent(filename) {
    return new File('/conf/', filename).text
}

//
// Set default timezone to "Europe/Brussels"
//
System.setProperty('org.apache.commons.jelly.tags.fmt.timeZone', getConfFileContent('timezone').trim())


//
// Create initial admin
//
//   thanks to https://gist.github.com/hayderimran7/50cb1244cc1e856873a4
//

def hudsonRealm = new HudsonPrivateSecurityRealm(false) ;
hudsonRealm.createAccount('admin','admin')
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

//
// Add ssh key to admin
//
//    thanks to @nigimaster https://gist.github.com/nigimaster/6a014c62b444fe7a7744304d66881451
//
def user = hudson.model.User.get('admin')
user.addProperty(new org.jenkinsci.main.modules.cli.auth.ssh.UserPropertyImpl(
   getConfFileContent('authorized_keys')
))
user.save()

//
// Allow connection over ssh
//
//   thanks to https://github.com/jenkins-infra/jenkins-infra/blob/staging/dist/profile/files/buildmaster/enable-ssh-port.groovy
//
def sshConfig = instance.getDescriptor('org.jenkinsci.main.modules.sshd.SSHD')
sshConfig.port = 22
sshConfig.save()

//
// Only one executor
//
instance.setNumExecutors(1)

//
// Self URL
//
jlc = JenkinsLocationConfiguration.get()
jlc.setUrl("http://localhost:18080/")
jlc.save()


//
// Add SSH key to connect to agents
//

// store = instance.getExtensionList("com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()
// privateKey = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource(
//   '''
// PRIVATE_KEY_TEXT
//   '''
// )

// sshKey = new BasicSSHUserPrivateKey(
//   CredentialsScope.GLOBAL,
//   "", // SECRET_TEXT
//   "admin", // PRIVATE_KEY_USERNAME
//   privateKey,
//   "", // PRIVATE_KEY_PASSPHRASE
//   "Uploaded by groovy" // SECRET_DESCRIPTION
// )
// store.addCredentials(Domain.global(), sshKey)


//
//
// Add credentials
//
//    thanks to https://support.cloudbees.com/hc/en-us/articles/217708168-Creating-credentials-using-Groovy?sort_by=votes
//

//
// User / password
//

// * github access token

// // Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL,java.util.UUID.randomUUID().toString(), "description", "user", "password")
// Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL,"initial-credentials", "description", "user", "password")
// SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)

//
// Certificate
//

// * packages gpg signature key

// String keyfile = "/tmp/key"
// def ksm1 = new CertificateCredentialsImpl.UploadedKeyStoreSource(keyfile)
// Credentials ck1 = new CertificateCredentialsImpl(CredentialsScope.GLOBAL,java.util.UUID.randomUUID().toString(), "description", "password", ksm1)
// SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), ck1)

//
// SSH Key
//

// * push packages files to github pages

// def source = new BasicSSHUserPrivateKey.DirectEntryPrivateKeySource("key")
// def ck1 = new BasicSSHUserPrivateKey(CredentialsScope.GLOBAL,java.util.UUID.randomUUID().toString(), "username", source, "passphrase", "description")
// SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), ck1)

//
// Save everything
//
instance.save()

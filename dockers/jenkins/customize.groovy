#!groovy

import jenkins.model.*

def instance = Jenkins.getInstance()

//
// Only one executor
//
//
instance.setNumExecutors(1)

jlc = JenkinsLocationConfiguration.get()
jlc.setUrl("http://192.168.100.2:18080/")
jlc.save()
//
//
// Create initial admin
//
//   thanks to https://gist.github.com/hayderimran7/50cb1244cc1e856873a4
//

import hudson.security.*

def hudsonRealm = new HudsonPrivateSecurityRealm(false) ;
hudsonRealm.createAccount('admin','admin')
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

instance.save()

//
//
// Add credentials
//
//    thanks to https://support.cloudbees.com/hc/en-us/articles/217708168-Creating-credentials-using-Groovy?sort_by=votes
//

import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*

//
// User / password
//

// * github access token

// Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL,java.util.UUID.randomUUID().toString(), "description", "user", "password")
   Credentials c = (Credentials) new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL,"initial-credentials", "description", "user", "password")
SystemCredentialsProvider.getInstance().getStore().addCredentials(Domain.global(), c)

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

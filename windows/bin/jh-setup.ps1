
. $PSScriptRoot\..\lib\require-admin.ps1

if (Enter-Admin) {
    Write-Output "This script is restated as admin"
    Exit 0
}

choco feature enable -n=allowGlobalConfirmation

choco install git
choco install docker-desktop
choco install vcbuildtools
choco install naps2
choco install mobaxterm
choco install hashtab
choco install psutils

# choco install meld
# choco install gradle
# choco install nano
# choco install jdk11 -params "static=false"
# choco install xmind

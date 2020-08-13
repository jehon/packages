#!/usr/bin/env bash

# Firewall -> https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/security_guide/sec-viewing_current_status_and_settings_of_firewalld

set -e

if [ "$(whoami)" != "root" ]; then
    echo "You must be root"
    exit 1
fi

if [ ! -d ~/tmp ]; then
    mkdir ~/tmp
fi

pushd ~/tmp

groupadd docker
usermod -a docker "$(uname -n)"
systemctl restart docker || true

yum -y install wget curl bash-completion bash-completion-extras nano yum-utils fuseiso sshpass

# Disable SELinux
setenforce 0
sed -i '/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# Docker
yum install -y device-mapper-persistent-data lvm2
# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker
systemctl restart docker

# VirtualBox
#wget https://www.virtualbox.org/download/oracle_vbox.asc
#rpm --import oracle_vbox.asc
yum-config-manager --add-repo http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
yum install -y kernel-devel-$(uname -r) kernel-headers gcc make perl VirtualBox-6.0

echo "VirtualBox check: "
systemctl status vboxdrv
wget https://download.virtualbox.org/virtualbox/6.0.14/Oracle_VM_VirtualBox_Extension_Pack-6.0.14.vbox-extpack -O vbextpack.vbox-extpack
vboxmanage extpack install vbextpack.vbox-extpack

# Install Git v2 (https://computingforgeeks.com/how-to-install-latest-version-of-git-git-2-x-on-centos-7/)
yum -y install  https://centos7.iuscommunity.org/ius-release.rpm
yum -y install  git2u-all

# Samba export (https://www.microlinux.fr/serveur-samba-centos-7/)
yum -y install samba samba-client
# semanage fcontext -a -t samba_share_t '/home/jhn/src'
firewall-cmd --permanent --zone=public --add-service=samba
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload
firewall-cmd --list-all

smbpasswd -a jhn
systemctl enable smb nmb
systemctl restart smb nmb

# nfs-exports
yum -y install nfs-utils

mkdir -p /home/public
chown nfsnobody:nfsnobody /home/public
chmod 755 /home/public
echo "/home/public        *(ro,root_squash,nohide,insecure)" >> /etc/exports
exportfs -a

systemctl enable nfs-server.service
systemctl restart nfs-server.service

# Patch /etc/samba/smb.conf
cat <<EOS >> /etc/samba/smb.conf
[src]
    path = /home/jhn/src
    comment = Sources
    read only = no
    valid users = jhn
    
[jhn-shared]
    path = /home/jhn/public
    comment = Public folder
    read only = Yes

EOS

# Snap (https://snapcraft.io/docs/installing-snap-on-centos)
yum -y install Snap
systemctl enable --now snapd.socket
ln -s /var/lib/snapd/snap /snap

snap install snapcraft
snap install shellcheck

snap install code-insider --classic
snap install filezilla --beta
sudo snap install node --channel=14/stable --classic

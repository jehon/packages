# Raspberry PI

## Root over samba

/boot/cmdline.txt:

console=serial0,115200 console=tty1 root=/dev/nfs nfsroot=<host>:/<path>,tcp rw rootfstype=nfs vers=3 ip=dhcp elevator=deadline rootwait

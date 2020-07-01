#!/bin/bash

echo "10.0.2.15     DC1.samba.example.com     DC1" >> /etc/hosts
smbd -b | grep "CONFIGFILE"
smbd -b | egrep "LOCKDIR|STATEDIR|CACHEDIR|PRIVATE_DIR"
rm /etc/krb5.conf

# detect os
# $os_version variables aren't always in use, but are kept here for convenience
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
	os_version=$(grep 'version_id' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
        apt-get update
        apt-get upgrade -y
	apt-get install acl attr samba samba-dsdb-modules samba-vfs-modules winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user ntp -y
elif [[ -e /etc/debian_version ]]; then
	os="debian"
	os_version=$(grep -oe '[0-9]+' /etc/debian_version | head -1)
        apt-get update
        apt-get upgrade -y
	apt-get install acl attr samba samba-dsdb-modules samba-vfs-modules winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user ntp -y
elif [[ -e /etc/centos-release ]]; then
	os="centos"
	os_version=$(grep -oe '[0-9]+' /etc/centos-release | head -1)
    yum install gcc gcc-c++ kernel-devel make wget git perl-Digest-SHA.x86_64 -y
    cd /root
    yum install samba
elif [[ -e /etc/fedora-release ]]; then
	os="fedora"
	os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1)
    yum install gcc gcc-c++ kernel-devel make wget git perl-Digest-SHA.x86_64 -y
    cd /root
    yum install samba
else
	echo "This installer seems to be running on an unsupported distribution.
Supported distributions are Ubuntu, Debian, CentOS, and Fedora."
	exit
fi

samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=samba.example.com --domain=samba --adminpass=1234567890!

echo search samba.example.com  >> /etc/resolv.conf 
echo nameserver 10.0.2.15  >> /etc/resolv.conf
samba-tool dns zonecreate DC1.samba.example.com 2.0.10.in-addr.arpa
cp /var/lib/samba/private/krb5.conf /etc/
systemctl stop smbd nmbd winbind
systemctl disable smbd nmbd winbind
systemctl unmask samba-ad-dc
systemctl start samba-ad-dc
systemctl enable samba-ad-dc
smbclient -L localhost -U%
smbclient //localhost/netlogon -UAdministrator -c 'ls'
samba-tool domain level show
samba-tool user create hluzardo

host -t SRV _ldap._tcp.samba.example.com.
host -t SRV _kerberos._udp.samba.example.com.
host -t A dc1.samba.example.com.

kinit administrator

klist


#!/bin/bash

# detect os
# $os_version variables aren't always in use, but are kept here for convenience
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
	os_version=$(grep 'version_id' /etc/os-release | cut -d '"' -f 2 | tr -d '.')
    apt-get update
    apt-get upgrade -y
	  apt-get install git build-essential wget shorewall -y
elif [[ -e /etc/debian_version ]]; then
	os="debian"
	os_version=$(grep -oe '[0-9]+' /etc/debian_version | head -1)
    apt-get update
    apt-get upgrade -y
	apt-get install git build-essential wget shorewall -y
elif [[ -e /etc/centos-release ]]; then
	os="centos"
	os_version=$(grep -oe '[0-9]+' /etc/centos-release | head -1)
    yum install gcc gcc-c++ kernel-devel make wget git perl-Digest-SHA.x86_64 -y
    cd /root
    wget http://www.invoca.ch/pub/packages/shorewall/RPMS/ils-8/noarch/shorewall-core-5.2.5.2-1.el8.noarch.rpm
    wget http://www.invoca.ch/pub/packages/shorewall/RPMS/ils-8/noarch/shorewall-5.2.5.2-1.el8.noarch.rpm
    rpm -i shorewall-core-5.2.5.2-1.el8.noarch.rpm
    rpm -i shorewall-5.2.5.2-1.el8.noarch.rpm
elif [[ -e /etc/fedora-release ]]; then
	os="fedora"
	os_version=$(grep -oE '[0-9]+' /etc/fedora-release | head -1)
    yum install gcc gcc-c++ kernel-devel make wget git perl-Digest-SHA.x86_64 -y
    cd /root

    wget http://www.invoca.ch/pub/packages/shorewall/RPMS/ils-8/noarch/shorewall-core-5.2.5.2-1.el8.noarch.rpm
    wget http://www.invoca.ch/pub/packages/shorewall/RPMS/ils-8/noarch/shorewall-5.2.5.2-1.el8.noarch.rpm
    rpm -i shorewall-core-5.2.5.2-1.el8.noarch.rpm
    rpm -i shorewall-5.2.5.2-1.el8.noarch.rpm
else
	echo "This installer seems to be running on an unsupported distribution.
Supported distributions are Ubuntu, Debian, CentOS, and Fedora."
	exit
fi

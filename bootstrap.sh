#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

function yum() {
  $(type -P yum) --disablerepo=updates "${@}"
}

# fix repo file.

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.saved

cat <<-'REPO' > /etc/yum.repos.d/CentOS-Base.repo
	[base]
	name=CentOS-$releasever - Base
	baseurl=http://centos.data-hotel.net/pub/linux/centos/$releasever/os/$basearch/
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

	[updates]
	name=CentOS-$releasever - Updates
	baseurl=http://centos.data-hotel.net/pub/linux/centos/$releasever/updates/$basearch/
	gpgcheck=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
	REPO


# Add installation packages ...
addpkgs="
 firstboot
"

if [[ -n "$(echo ${addpkgs})" ]]; then
  yum install -y ${addpkgs}
fi

if [[ -f /etc/yum/vars/releasever ]]; then
  rm  -f /etc/yum/vars/releasever
fi

# 6.4 -> 6.5

{
  ls -la /etc/sysconfig/firstboot || :
  rpm -qi firstboot
  chkconfig --list firstboot
} | tee /vagrant/firstboot.before

yum update -y

{
  ls -la /etc/sysconfig/firstboot || :
  rpm -qi firstboot
  chkconfig --list firstboot
} | tee /vagrant/firstboot.after

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

#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

[ -f  /vagrant/proxy.env ] && source /vagrant/proxy.env

BASE="`docker images -q ol7-glibc:${DATE}`"

if [ $BASE ]; then
  echo "skipping: found image ${BASE} for today ${DATE}"
else
  mkdir -p /root/ol7-glibc/etc/yum.repos.d
  cp /etc/resolv.conf /root/ol7-glibc/etc/
  curl -sSL http://public-yum.oracle.com/public-yum-ol7.repo -o /root/ol7-glibc/etc/yum.repos.d/public-yum-ol7.repo
  curl -sSL https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -o /root/ol7-glibc/epel-release-latest-7.noarch.rpm
  yum-config-manager --installroot=/root/ol7-glibc --enable ol7_addons
  yum-config-manager --installroot=/root/ol7-glibc --enable ol7_optional_latest
  yum-config-manager --installroot=/root/ol7-glibc --enable ol7_software_collections
  yum-config-manager --installroot=/root/ol7-glibc --enable ol7_UEKR4
  yum-config-manager --installroot=/root/ol7-glibc --disable ol7_UEKR3
  yum --installroot=/root/ol7-glibc install -y glibc
  #epel
  yum --installroot=/root/ol7-glibc localinstall -y /root/ol7/epel-release-latest-7.noarch.rpm
  yum-config-manager --installroot=/root/ol7-glibc --disable epel
  rm /root/ol7/epel-release-latest-7.noarch.rpm

  #clean chroot
  yum --installroot=/root/ol7-glibc clean all
  rm -fr /root/ol7-glibc/var/cache/yum/
  > /root/ol7-glibc/etc/resolv.conf

  #create docker image
  pushd /root/ol7-glibc
  tar -c . --numeric-owner -f /vagrant/ol7-glibc.chroot.tar 
  cat /vagrant/ol7-glibc.chroot.tar | docker import - ol7-glibc
  docker tag ol7-glibc:latest ol7-glibc:${DATE}
  docker save ol7-glibc:latest > /vagrant/ol7-glibc.docker.tar
  popd
fi

#the dockers
pushd /vagrant/dockerfiles
popd

#simple test

#delete <none> images
NONE="`docker images -q --filter "dangling=true"`"
[ "${NONE}" ] && docker rmi -f ${NONE}

#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

BASE="`docker images -q ol7:${DATE}`"

if [ $BASE ]; then
  echo "skipping: found image ${BASE} for today ${DATE}"
else
  mkdir -p /root/ol7/etc/yum.repos.d
  cp /etc/resolv.conf /root/ol7/etc/
  curl -sSL http://public-yum.oracle.com/public-yum-ol7.repo -o /root/ol7/etc/yum.repos.d/public-yum-ol7.repo
  curl -sSL https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -o /root/ol7/epel-release-latest-7.noarch.rpm
  yum-config-manager --installroot=/root/ol7 --enable ol7_addons
  yum-config-manager --installroot=/root/ol7 --enable ol7_optional_latest
  yum-config-manager --installroot=/root/ol7 --enable ol7_software_collections
  yum-config-manager --installroot=/root/ol7 --enable ol7_UEKR4
  yum-config-manager --installroot=/root/ol7 --disable ol7_UEKR3
  yum --installroot=/root/ol7 install -y glibc bash rpm yum yum-utils sudo
  chroot /root/ol7 rpm --import http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol7
  #epel
  yum --installroot=/root/ol7 localinstall -y /root/ol7/epel-release-latest-7.noarch.rpm
  yum-config-manager --installroot=/root/ol7 --disable epel
  rm /root/ol7/epel-release-latest-7.noarch.rpm

  #clean chroot
  yum --installroot=/root/ol7 clean all
  rm -fr /root/ol7/var/cache/yum/
  > /root/ol7/etc/resolv.conf

  #create docker image
  pushd /root/ol7
  tar -c . --numeric-owner -f /vagrant/ol7.chroot.tar 
  cat /vagrant/ol7.chroot.tar | docker import - ol7
  docker tag ol7:latest ol7:${DATE}
  docker save ol7:latest > /vagrant/ol7.docker.tar
  popd
fi

#the dockers
pushd /vagrant/dockerfiles
docker build -t ol7-gcc48 ol7-gcc48/.
docker tag ol7-gcc48:latest ol7-gcc48:${DATE}
docker build -t ol7-webserver-php55 ol7-webserver-php55/.
docker tag ol7-webserver-php55:latest ol7-webserver-php55:${DATE}
docker build -t ol7-php55info-cli ol7-php55info-cli/.
docker tag ol7-php55info-cli:latest ol7-php55info-cli:${DATE}
popd

#simple test
docker run ol7-gcc48:${DATE} gcc --version
docker run ol7-php55info-cli:${DATE} php -v

#delete <none> images
NONE="`docker images -q --filter "dangling=true"`"
[ "${NONE}" ] && docker rmi -f ${NONE}

#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

[ -f  /vagrant/proxy.env ] && source /vagrant/proxy.env

BASE="`docker images -q trusty:${DATE}`"

if [ $BASE ]; then
  echo "skipping: found image ${BASE} for today ${DATE}"
else
  # update trusty if exists
  # install if doesnt
  if [ -d /root/trusty ]; then
    cp /etc/resolv.conf /root/trusty/etc/resolv.conf
    chroot /root/trusty apt-get update
    chroot /root/trusty apt-get dist-upgrade -y
  elif [ ! -d /root/trusty ] && [ -f /vagrant/trusty.chroot.tar ]; then
    mkdir -p /root/trusty
    tar xf /vagrant/trusty.chroot.tar --numeric-owner -C /root/trusty/
    cp /etc/resolv.conf /root/trusty/etc/resolv.conf
    chroot /root/trusty apt-get update
    chroot /root/trusty apt-get dist-upgrade -y
  else
    debootstrap trusty /root/trusty
  fi

  #clean chroot
  chroot /root/trusty apt-get clean
  > /root/trusty/etc/resolv.conf

  #create docker image
  pushd /root/trusty
  tar -c . --numeric-owner -f /vagrant/trusty.chroot.tar 
  cat /vagrant/trusty.chroot.tar | docker import - trusty
  docker tag trusty:latest trusty:${DATE}
  docker save trusty:latest > /vagrant/trusty.docker.tar
  popd
fi

#the dockers
pushd /vagrant/dockerfiles
docker build -t trusty-webserver-php5 trusty-webserver-php5/.
docker tag trusty-webserver-php5:latest trusty-webserver-php5:${DATE}
docker build -t trusty-php5info-cli trusty-php5info-cli/.
docker tag trusty-php5info-cli:latest trusty-php5info-cli:${DATE}
popd

#simple test for php5
docker run trusty-php5info-cli:${DATE} php -v

#delete <none> images
NONE="`docker images -q --filter "dangling=true"`"
[ "${NONE}" ] && docker rmi -f ${NONE}

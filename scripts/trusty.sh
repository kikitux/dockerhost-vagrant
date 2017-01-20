#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

#[ -f  /vagrant/proxy.env ] && source /vagrant/proxy.env

#delete <none> images
NONE="`docker images -q --filter "dangling=true"`"
[ "${NONE}" ] && docker rmi -f ${NONE} || true

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

true

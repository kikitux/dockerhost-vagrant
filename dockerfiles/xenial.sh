#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

[ -f  /vagrant/proxy.env ] && source /vagrant/proxy.env

BASE="`docker images -q xenial:${DATE}`"

if [ $BASE ]; then
  echo "skipping: found image ${BASE} for today ${DATE}"
else
  # update xenial if exists
  # install if doesnt
  if [ -d /root/xenial ]; then
    cp /etc/resolv.conf /root/xenial/etc/resolv.conf
    chroot /root/xenial apt-get update
    chroot /root/xenial apt-get dist-upgrade -y
    chroot /root/xenial apt-get install -y software-properties-common
    echo | chroot /root/xenial add-apt-repository ppa:ubuntu-toolchain-r/test
    chroot /root/xenial apt-get update
    chroot /root/xenial apt-get dist-upgrade -y
  elif [ ! -d /root/xenial ] && [ -f /vagrant/xenial.chroot.tar ]; then
    mkdir -p /root/xenial
    tar xf /vagrant/xenial.chroot.tar --numeric-owner -C /root/xenial/
    cp /etc/resolv.conf /root/xenial/etc/resolv.conf
    chroot /root/xenial apt-get update
    chroot /root/xenial apt-get dist-upgrade -y
    chroot /root/xenial apt-get install -y software-properties-common
    echo | chroot /root/xenial add-apt-repository ppa:ubuntu-toolchain-r/test
    chroot /root/xenial apt-get update
    chroot /root/xenial apt-get dist-upgrade -y
  else
    debootstrap xenial /root/xenial
    chroot /root/xenial apt-get install -y software-properties-common
    echo | chroot /root/xenial add-apt-repository ppa:ubuntu-toolchain-r/test
    chroot /root/xenial apt-get update
    chroot /root/xenial apt-get dist-upgrade -y
  fi

  #clean chroot
  chroot /root/xenial apt-get clean
  > /root/xenial/etc/resolv.conf

  #create docker image
  pushd /root/xenial
  tar -c . --numeric-owner -f /vagrant/xenial.chroot.tar 
  cat /vagrant/xenial.chroot.tar | docker import - xenial
  docker tag xenial:latest xenial:${DATE}
  docker save xenial:latest > /vagrant/xenial.docker.tar
  popd
fi

#the dockers
pushd /vagrant/dockerfiles
docker build -t xenial-gcc6 xenial-gcc6/.
docker tag xenial-gcc6:latest xenial-gcc6:${DATE}
popd

#simple test
docker run xenial-gcc6:${DATE} gcc --version

#delete <none> images
NONE="`docker images -q --filter "dangling=true"`"
[ "${NONE}" ] && docker rmi -f ${NONE}

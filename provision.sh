#!/bin/bash
set -e
DATE="`date +%Y%m%d`"

which debootstrap curl || {
  apt-get clean
  apt-get update
  apt-get install -y debootstrap curl
}

which docker || {
  curl -fsSL https://experimental.docker.com/ | bash
}

# update ubuntu if exists
# install if doesnt
if [ -d /root/ubuntu ]; then
  cp /etc/resolv.conf /root/ubuntu/etc/resolv.conf
  chroot /root/ubuntu apt-get update
  chroot /root/ubuntu apt-get dist-upgrade
elif [ ! -d /root/ubuntu ] && [ -f /vagrant/ubuntu.chroot.tar ]; then
  mkdir -p /root/ubuntu
  tar xf /vagrant/ubuntu.chroot.tar --numeric-owner -C /root/ubuntu/
  cp /etc/resolv.conf /root/ubuntu/etc/resolv.conf
  chroot /root/ubuntu apt-get update
  chroot /root/ubuntu apt-get dist-upgrade
else
  debootstrap trusty /root/ubuntu
fi

#clean chroot
chroot /root/ubuntu apt-get clean
> /root/ubuntu/etc/resolv.conf

#create docker image
pushd /root/ubuntu
tar -c . --numeric-owner -f /vagrant/ubuntu.chroot.tar 
cat /vagrant/ubuntu.chroot.tar | docker import - ubuntu
docker tag ubuntu:latest ubuntu:${DATE}
docker save ubuntu:latest > /vagrant/ubuntu.docker.tar
popd

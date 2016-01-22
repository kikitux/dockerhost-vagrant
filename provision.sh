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
else
  debootstrap trusty /root/ubuntu
fi

#clean chroot
chroot /root/ubuntu apt-get clean
> /root/ubuntu/etc/resolv.conf

#create docker image
pushd /root/ubuntu
tar -c . --numeric-owner | docker import - ubuntu
docker tag ubuntu:latest ubuntu:${DATE}
popd

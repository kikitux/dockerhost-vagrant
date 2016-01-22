#!/bin/bash
DATE="`date +%Y%m%d`"

which debootstrap curl || {
  apt-get install -y debootstrap curl
}

which docker || {
  curl -fsSL https://experimental.docker.com/ | bash
  usermod -a -G docker vagrant
}

service docker restart

BASE="`docker images -q ubuntu:${DATE}`"

if [ $BASE ]; then
  echo "skipping: found image ${BASE} for today ${DATE}"
else
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
fi

#the dockers
pushd /vagrant/dockerfiles
docker build -t ubuntu-webserver-php5 ubuntu-webserver-php5/.
docker tag ubuntu-webserver-php5:latest ubuntu-webserver-php5:${DATE}
docker build -t phpinfo-cli phpinfo-cli/.
docker tag phpinfo-cli:latest phpinfo-cli:${DATE}
popd

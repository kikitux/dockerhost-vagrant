#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

[ -f  /vagrant/proxy.env ] && source /vagrant/proxy.env

#for deb os
which debootstrap curl || {
  apt-get install -y debootstrap curl
}

#for rpm os
which yum-utils yum rpm || {
  apt-get install -y yum-utils yum rpm
}

which docker || {
  curl -fsSL https://experimental.docker.com/ | bash
  usermod -a -G docker vagrant
}

service docker restart
chown vagrant:docker /var/run/docker.sock
ls -al /var/run/docker.sock

#!/bin/bash
#%Y Year, %V Week 
DATE="`date +%Y%V`"

which debootstrap curl || {
  apt-get install -y debootstrap curl
}

which docker || {
  curl -fsSL https://experimental.docker.com/ | bash
  usermod -a -G docker vagrant
}

service docker restart

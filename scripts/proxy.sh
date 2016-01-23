#!/bin/bash

which polipo || {
  apt-get install -y polipo
}

http_proxy="http://127.0.0.1:8123" curl -sSL http://google.com &>/dev/null
if [ $? -eq 0 ]; then
  #proxy.env
  echo 'export http_proxy="http://127.0.0.1:8123"' > /vagrant/proxy.env
  echo 'export HTTP_PROXY="http://127.0.0.1:8123"' >> /vagrant/proxy.env
  echo 'export https_proxy="http://127.0.0.1:8123"' >> /vagrant/proxy.env
  echo 'export HTTPS_PROXY="http://127.0.0.1:8123"' >> /vagrant/proxy.env
  #sudoers
  echo 'Defaults env_keep = "http_proxy HTTP_PROXY https_proxy HTTPS_PROXY ftp_proxy"' > /etc/sudoers.d/proxy
  #apt
  echo 'Acquire::http::proxy "http://127.0.0.1:8123";' >  /etc/apt/apt.conf.d/30proxy 
  echo 'Acquire::https::proxy "https://127.0.0.1:8123";' >> /etc/apt/apt.conf.d/30proxy 
  #profile
  echo '[ -f  /vagrant/proxy.env ] && source /vagrant/proxy.env' > /etc/profile.d/proxy.sh
else
  > /vagrant/proxy.env
  > /etc/sudoers.d/proxy
  > /etc/apt/apt.conf.d/30proxy
  > /etc/profile.d/proxy.sh
fi

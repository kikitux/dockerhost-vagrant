#!/bin/bash

which polipo || {
  apt-get install -y polipo
}

http_proxy="http://127.0.0.1:8123" curl -sSL http://google.com &>/dev/null
if [ $? -eq 0 ]; then
  echo 'export http_proxy="http://127.0.0.1:8123"' > /vagrant/proxy.env
  echo 'export HTTP_PROXY="http://127.0.0.1:8123"' >> /vagrant/proxy.env
  echo 'Defaults env_keep = "http_proxy ftp_proxy"' > /etc/sudoers.d/proxy
else
  > /vagrant/proxy.env
  > /etc/sudoers.d/proxy
fi

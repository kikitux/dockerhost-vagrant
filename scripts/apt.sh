#!/bin/bash
apt-get clean all
cat >/etc/apt/sources.list << EOF
#NZ
deb http://extras.ubuntu.com/ubuntu trusty main
deb http://nz.archive.ubuntu.com/ubuntu/ trusty-backports main restricted universe multiverse
deb http://nz.archive.ubuntu.com/ubuntu/ trusty main restricted
deb http://nz.archive.ubuntu.com/ubuntu/ trusty multiverse
deb http://nz.archive.ubuntu.com/ubuntu/ trusty universe
deb http://nz.archive.ubuntu.com/ubuntu/ trusty-updates main restricted
deb http://nz.archive.ubuntu.com/ubuntu/ trusty-updates multiverse
deb http://nz.archive.ubuntu.com/ubuntu/ trusty-updates universe
deb http://security.ubuntu.com/ubuntu trusty-security main restricted
deb http://security.ubuntu.com/ubuntu trusty-security multiverse
deb http://security.ubuntu.com/ubuntu trusty-security universe
EOF

apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 16126D3A3E5C1192

apt-get update

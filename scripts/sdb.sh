#!/bin/bash

[ -f  /vagrant/proxy.env ] && source /vagrant/proxy.env

#install btrfs-tools if not present
which btrfs || {
  apt-get install -y btrfs-tools
}

#check for device /dev/sdb
[ -b /dev/sdb ]

#format if no metadata present
blkid /dev/sdb*
if [ $? -ne 0 ]; then
  mkfs.btrfs -m single -d single /dev/sdb
  blkid /dev/sdb 2>&1>/dev/null && echo $(blkid /dev/sdb -o export | head -n1) /var/lib/docker auto defaults 0 0 >> /etc/fstab
  mkdir -p /var/lib/docker
  mount /var/lib/docker
else
  echo "filesystem metadata found on sdb, ignoring"
fi


#!/bin/bash

#%Y Year, %V Week 
DATE="`date +%Y%V`"

[ -f  /vagrant/proxy.env ] && source /vagrant/proxy.env

#the dockers
pushd /vagrant/dockerfiles
docker build -t trusty-webserver-php5 trusty-webserver-php5/.
docker tag trusty-webserver-php5:latest trusty-webserver-php5:${DATE}
docker build -t trusty-php5info-cli trusty-php5info-cli/.
docker tag trusty-php5info-cli:latest trusty-php5info-cli:${DATE}
popd

#simple test for php5
docker run trusty-php5info-cli:${DATE} php -v




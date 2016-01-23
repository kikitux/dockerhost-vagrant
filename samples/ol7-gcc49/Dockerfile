FROM ol7
RUN yum install -y devtoolset-3-gcc devtoolset-3-gcc-c++ devtoolset-3-gcc-gfortran &&\
    alternatives --install /usr/bin/gcc gcc /opt/rh/devtoolset-3/root/usr/bin/gcc 1 --slave /usr/bin/g++ g++ /opt/rh/devtoolset-3/root/usr/bin/g++ &&\
    yum clean all &&\
    rm -fr /root/ol7/var/cache/yum/

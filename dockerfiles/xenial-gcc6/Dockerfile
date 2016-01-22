FROM xenial
RUN sudo apt-get update && \
    sudo apt-get install -y gcc-6 g++-6 && \
    sudo apt-get clean

#RUN sudo update-alternatives --remove-all gcc && \
#RUN sudo update-alternatives --remove-all g++ && \

RUN sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 20 && \
    sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 20 && \
    sudo update-alternatives --config gcc && \
    sudo update-alternatives --config g++

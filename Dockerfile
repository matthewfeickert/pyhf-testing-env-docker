FROM ubuntu:bionic

MAINTAINER Matthew Feickert <matthew.feickert@cern.ch>

ENV HOME /root
WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

# Install general dependencies
RUN apt-get -qq -y update \
    && apt-get -qq -y upgrade \
    && apt-get -qq -y install \
    gcc \
    g++ \
    git \
    zlibc \
    zlib1g-dev \
    libssl-dev \
    libbz2-dev \
    wget \
    make \
    software-properties-common \
    vim \
    emacs

# Install Python 3.6
RUN wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz \
    && tar -xvzf Python-3.6.6.tgz > /dev/null \
    && rm Python-3.6.6.tgz
RUN cd Python-3.6.6 \
    && ./configure --with-bz2 \
    && make \
    && make install
RUN echo "alias python=python3" >> ~/.bashrc
RUN pip3 install --upgrade --quiet pip setuptools wheel

# Install pyhf development environment
RUN git clone https://github.com/diana-hep/pyhf.git \
    && cd pyhf \
    && pip3 install --upgrade -e .[develop,tensorflow,mxnet,torch]

RUN rm -rf /var/lib/apt-get/lists/* \
    && rm -rf /root/Python-3.6.6

# Define working directory
WORKDIR /data
VOLUME [ "/root" ]

CMD [ "/bin/bash" ]

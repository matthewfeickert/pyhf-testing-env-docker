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
    emacs \
    cmake \
    cpio \
    gfortran

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

# Install MKL
RUN cd /tmp \
  && wget http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11306/l_mkl_2017.2.174.tgz \
  && tar -xzf l_mkl_2017.2.174.tgz \
  && cd l_mkl_2017.2.174 \
  && sed -i 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg \
  && ./install.sh -s silent.cfg \
  && cd .. \
  && rm -rf * \
  && echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/intel.conf \
  && ldconfig \
  && echo ". /opt/intel/bin/compilervars.sh intel64" >> /etc/bash.bashrc

# Install numpy with MKL
RUN pip install Cython

RUN cd /tmp \
    && git clone https://github.com/numpy/numpy.git numpy \
    && cd numpy \
    && cp site.cfg.example site.cfg \
    && echo "\n[mkl]" >> site.cfg \
    && echo "include_dirs = /opt/intel/mkl/include/intel64/" >> site.cfg \
    && echo "library_dirs = /opt/intel/mkl/lib/intel64/" >> site.cfg \
    && echo "mkl_libs = mkl_rt" >> site.cfg \
    && echo "lapack_libs =" >> site.cfg \
    && python setup.py build --fcompiler=gnu95 \
    && python setup.py install \
    && cd .. \
    && rm -rf *

# Install scipy
RUN cd /tmp \
    && git clone https://github.com/scipy/scipy.git scipy \
    && cd scipy \
    && python setup.py build \
    && python setup.py install \
    && cd .. \
    && rm -rf *

# Install pyhf development environment
RUN git clone https://github.com/diana-hep/pyhf.git \
    && cd pyhf \
    && pip3 install --upgrade -e .[tensorflow,torch,mxnet,develop]

RUN rm -rf /var/lib/apt-get/lists/* \
    && rm -rf /root/Python-3.6.6

# Define working directory
WORKDIR /data
VOLUME [ "/root" ]

CMD [ "/bin/bash" ]

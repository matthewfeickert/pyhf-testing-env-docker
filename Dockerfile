FROM matthewfeickert/docker-python3-ubuntu:latest

MAINTAINER Matthew Feickert <matthewfeickert@users.noreply.github.com>

USER root
ENV USER root

RUN pip3 install --upgrade --no-cache-dir pip setuptools wheel

# Install MKL using releases from https://github.com/intel/mkl-dnn/releases
RUN cd /tmp && \
  wget http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/11306/l_mkl_2017.2.174.tgz && \
  tar -xzf l_mkl_2017.2.174.tgz && \
  cd l_mkl_2017.2.174 && \
  sed -i 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g' silent.cfg && \
  ./install.sh -s silent.cfg && \
  cd .. && \
  rm -rf * && \
  echo "/opt/intel/mkl/lib/intel64" >> /etc/ld.so.conf.d/intel.conf && \
  ldconfig && \
  echo ". /opt/intel/bin/compilervars.sh intel64" >> /etc/bash.bashrc

# Install numpy with MKL
RUN pip3 install Cython

RUN cd /tmp && \
    git clone https://github.com/numpy/numpy.git numpy && \
    cd numpy && \
    cp site.cfg.example site.cfg && \
    echo "&& \n[mkl]" >> site.cfg && \
    echo "include_dirs = /opt/intel/mkl/include/intel64/" >> site.cfg && \
    echo "library_dirs = /opt/intel/mkl/lib/intel64/" >> site.cfg && \
    echo "mkl_libs = mkl_rt" >> site.cfg && \
    echo "lapack_libs =" >> site.cfg && \
    python3 setup.py build --fcompiler=gnu95 && \
    python3 setup.py install && \
    cd .. && \
    rm -rf *

# Install scipy
RUN cd /tmp && \
    git clone https://github.com/scipy/scipy.git scipy && \
    cd scipy && \
    python3 setup.py build && \
    python3 setup.py install && \
    cd .. && \
    rm -rf *

# Install pyhf development environment
RUN git clone https://github.com/diana-hep/pyhf.git && \
    cd pyhf && \
    pip3 install --no-cache-dir --upgrade -e .[complete]

ENV USER docker

CMD [ "/bin/bash" ]

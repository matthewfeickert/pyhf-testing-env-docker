FROM ubuntu:xenial

MAINTAINER Matthew Feickert <matthew.feickert@cern.ch>

ENV HOME /root
WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

# Install general dependencies
RUN apt-get -qq -y update
RUN apt-get -qq -y install \
    wget \
    python \
    python-dev \
    python-pip \
    python-virtualenv \
    git \
    vim

# Install miniconda to /miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
RUN bash miniconda.sh -p /miniconda -b
RUN rm miniconda.sh
ENV PATH="/miniconda/bin:${PATH}"
RUN conda update -y conda
RUN conda info -a

# Install PyTorch with Conda
RUN conda install -q -y \
    pytorch \
    scipy \
    -c pytorch

RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /root/*

# Define working directory
WORKDIR /data
VOLUME [ "/root" ]

CMD [ "/bin/bash" ]

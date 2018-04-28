FROM ubuntu:xenial

MAINTAINER Matthew Feickert <matthew.feickert@cern.ch>

ENV HOME /root
WORKDIR /root

SHELL [ "/bin/bash", "-c" ]

# Install general dependencies
RUN apt -qq -y update
RUN apt -qq -y upgrade
RUN apt -qq -y install \
    wget \
    software-properties-common \
    git \
    vim

# Install Python 3.6
# https://stackoverflow.com/a/44254088/8931942
RUN add-apt-repository -y ppa:jonathonf/python-3.6 && \
    apt -qq -y update
RUN apt -qq -y install \
    python3.6 \
    python3.6-dev \
    python3.6-venv
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py
RUN ln -s /usr/bin/python3.6 /usr/local/bin/python3
RUN echo "alias python=python3" >> ~/.bashrc && \
    source ~/.bashrc

# Install pyhf
# RUN git clone https://github.com/diana-hep/pyhf.git && cd pyhf
# RUN pip install -U --process-dependency-links -e .[develop] && \
#     pip install --upgrade pytest

RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /root/*

# Define working directory
WORKDIR /data
VOLUME [ "/root" ]

CMD [ "/bin/bash" ]

FROM node:8-stretch

RUN perl -i -ne '/^\s*deb-src/ && next; s/(^\s*deb)(\s.+)/"$1$2\n$1-src$2\n"/e; print' /etc/apt/sources.list /etc/apt/sources.list.d/*
RUN apt-get update

RUN : \
  && apt-get install -y apt-utils \
  && apt-get install -y \
          build-essential:native \
          debhelper \
          gccgo-6 \
          gcj-jdk \
          gdc-6 \
          gfortran-6 \
          gobjc++-6 \
          gobjc-6 \
          libgphobos-6-dev \
          lsb-release \
  && :

RUN apt-get source -b gcc-multilib
RUN dpkg -i *.deb
RUN rm *.deb
RUN apt-get install -y -f
RUN apt-get source -b g++-multilib
RUN dpkg -i *.deb
RUN rm *.deb
RUN apt-get install -y -f

RUN apt-get install -y \
  bison \
  build-essential \
  curl \
  git \
  gperf \
  libgnome-keyring-dev \
  libnotify-dev \
  libssl-dev \
  lsb-release \
  ninja-build \
  python-pip \
  sudo

RUN npm install -g node-gyp@3.3.1
RUN pip install Jinja2==2.8.1

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install sccache
RUN echo "sccache = /root/.cargo/bin/sccache" > /root/.npmrc

# BLB source code. Mount ./browser-laptop-bootstrap from the host to here.
WORKDIR /src
VOLUME /src

# Build cache. Mount ./sccache from the host to here.
VOLUME /root/.cache/sccache

CMD bash

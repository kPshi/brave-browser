FROM node:8-stretch

RUN perl -i -ne '/^\s*deb-src/ && next; s/(^\s*deb)(\s.+)/"$1$2\n$1-src$2\n"/e; print' /etc/apt/sources.list /etc/apt/sources.list.d/*

ENV http_proxy=http://172.17.0.1:3128
ENV https_proxy=http://172.17.0.1:3128

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
          bison \
          curl \
          git \
          gperf \
          libgnome-keyring-dev \
          libnotify-dev \
          libssl-dev \
          lsb-release \
          ninja-build \
          python-pip \
          sudo \
  && apt-get clean all \
  && :

RUN : \
  && apt-get source -b gcc-multilib \
  && dpkg -i *.deb \
  && rm *.deb \
  && apt-get install -y -f \
  && apt-get clean all \
  && :

RUN : \
  && apt-get source -b g++-multilib \
  && dpkg -i *.deb \
  && rm *.deb \
  && apt-get install -y -f \
  && apt-get clean all \
  && :

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

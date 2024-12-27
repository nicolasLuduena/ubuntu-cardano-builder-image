ARG UBUNTU_VERSION=20.04
FROM ubuntu:$UBUNTU_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake bash binutils curl dpkg fakeroot file \
    g++ gcc git make perl tar xz-utils \
    ca-certificates \
    libbrotli-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libgmp-dev \
    libffi-dev \
    libpng-dev \
    libncurses-dev \
    libssl-dev \
    libpcre3-dev \
    libsdl2-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-ttf-dev \
    liblzma-dev \
    zlib1g-dev \
    libtool pkg-config \
    locales locales-all && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN curl --proto '=https' --tlsv1.2 -sSf \
    https://get-ghcup.haskell.org | BOOTSTRAP_HASKELL_NONINTERACTIVE=1 \
    BOOTSTRAP_HASKELL_ADJUST_BASHRC=P sh

ENV PATH="/root/.ghcup/bin:$PATH"

ENV SODIUM_VERSION=dbb48cc
RUN git clone https://github.com/intersectmbo/libsodium && \
    cd libsodium && \
    git checkout $SODIUM_VERSION && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make check && \
    make install

ENV SECP256K1_VERSION=v0.3.2
RUN git clone --depth 1 --branch ${SECP256K1_VERSION} https://github.com/bitcoin-core/secp256k1 && \
    cd secp256k1 && \
    ./autogen.sh && \
    ./configure --enable-module-schnorrsig --enable-experimental && \
    make && \
    make check && \
    make install

ENV BLST_VERSION=v0.3.11
RUN git clone --depth 1 --branch ${BLST_VERSION} https://github.com/supranational/blst && \
    cd blst && \
    ./build.sh && \
    echo "prefix=/usr/local" > libblst.pc && \
    echo "exec_prefix=\${prefix}" >> libblst.pc && \
    echo "libdir=\${exec_prefix}/lib" >> libblst.pc && \
    echo "includedir=\${prefix}/include" >> libblst.pc && \
    echo "Name: libblst" >> libblst.pc && \
    echo "Description: Multilingual BLS12-381 signature library" >> libblst.pc && \
    echo "URL: https://github.com/supranational/blst" >> libblst.pc && \
    echo "Version: ${BLST_VERSION#v}" >> libblst.pc && \
    echo "Cflags: -I\${includedir}" >> libblst.pc && \
    echo "Libs: -L\${libdir} -lblst" >> libblst.pc && \
    cp libblst.pc /usr/local/lib/pkgconfig/ && \
    cp bindings/blst_aux.h bindings/blst.h bindings/blst.hpp /usr/local/include/ && \
    cp libblst.a /usr/local/lib

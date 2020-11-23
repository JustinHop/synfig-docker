#FROM nvidia/opengl:base-ubuntu20.04
FROM nvidia/opengl:base-ubuntu20.04 AS base
LABEL maintainer="Justin Hoppensteadt <justinrocksmadscience+git@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        bzip2 \
        ca-certificates \
        fontconfig \
        imagemagick \
        synfig \
        synfig-examples \
        synfigstudio \
        libatk1.0 \
        libfftw3-bin \
        libfontconfig1 \
        libfreetype6 \
        libegl-mesa0 \
        libglibmm-2.4 \
        libgtkmm-3.0 \
        libjack0 \
        libmng2 \
        libopengl0 \
        libpng-tools \
        libsdl2-mixer-2.0-0 \
        libtiff5 \
        libxml2 \
        libxslt1.1 python python3-lxml \
        && \
    apt-get -y autoremove && \
    apt-get -y purge \
        synfig \
        synfigstudio \
        synfig-examples



FROM base AS build
RUN apt-get -y --no-install-recommends install \
        git
RUN cd /tmp && \
    git clone https://github.com/synfig/synfig.git
RUN cd /tmp/synfig && \
    git checkout v1.4.0
RUN cat /etc/apt/sources.list | sed -e 's!^deb!deb-src!' > /tmp/sources.list && \
    cat /tmp/sources.list | tee -a /etc/apt/sources.list && rm /tmp/sources.list && \
    apt-get -y update && \
    apt-get -y --no-install-recommends build-dep \
        synfig \
        synfigstudio \
        synfig-examples \
        && \
    apt-get -y --no-install-recommends install \
        build-essential \
        autoconf automake autopoint \
        gettext \
        intltool \
        libatk1.0-dev \
        libboost-system-dev \
        libfftw3-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libgl1-mesa-dev \
        libglibmm-2.4-dev \
        libgtkmm-3.0-dev \
        libjack-jackd2-dev \
        libltdl3-dev \
        libmagick++-dev \
        libmlt-dev libmlt++-dev libmlt-data \
        libmng-dev \
        libopengl-dev \
        libpng-dev \
        libsdl2-dev \
        libsdl2-mixer-dev \
        libsigc++-2.0-dev \
        libtiff5-dev \
        libtool \
        libxml++2.6-dev \
        libxml2-dev \
        libxslt-dev python-dev python3-lxml \
        shared-mime-info \
        x11proto-xext-dev libdirectfb-dev libxfixes-dev libxinerama-dev libxdamage-dev libxcomposite-dev libxcursor-dev libxft-dev libxrender-dev libxt-dev libxrandr-dev libxi-dev libxext-dev libx11-dev \
        pkg-config
WORKDIR /tmp/synfig
RUN mkdir build && \
    echo "PREFIX=/synfig\nMAKE_THREADS=4\nDEBUG=''" > build/build.conf
WORKDIR /tmp/synfig/build
RUN /tmp/synfig/autobuild/build.sh all full
RUN apt-get -y clean && \
    rm -rf /var/cache/apt



FROM base AS release
COPY --from=build /synfig /synfig
RUN groupadd -r -g 1000 justin && \
    useradd -d /home/justin -m --shell /sbin/nologin --uid 1000 -g 1000 justin
WORKDIR /home/justin
USER justin
RUN mkdir -p /home/justin/Downloads /home/justin/synfig /home/justin/art /home/justin/.config/synfig
ENTRYPOINT "/synfig/bin/synfigstudio"

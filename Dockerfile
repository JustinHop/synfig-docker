FROM nvidia/opengl:base-ubuntu20.04 AS base
LABEL maintainer="Justin Hoppensteadt <justinrocksmadscience+git@gmail.com>"
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        synfig \
        synfigstudio \
        synfig-examples \
        && \
    apt-get -y autoremove && \
    apt-get -y purge \
        synfig \
        synfigstudio \
        synfig-examples



FROM base AS build
RUN cat /etc/apt/sources.list | sed -e 's!^deb!deb-src!' > /tmp/sources.list && \
    cat /tmp/sources.list | tee -a /etc/apt/sources.list && rm /tmp/sources.list && \
    apt-get -y update && \
    apt-get -y --no-install-recommends build-dep \
        synfig \
        synfigstudio \
        synfig-examples \
        && \
    apt-get -y --no-install-recommends install \
        git \
        pkg-config \
        && \
    apt-get -y clean && \
    rm -rf /var/cache/apt
RUN cd /tmp && \
    git clone --depth 1 https://github.com/synfig/synfig.git
WORKDIR /tmp/synfig
RUN mkdir build && \
    echo "PREFIX=/synfig\nMAKE_THREADS=4\nDEBUG=''" > build/build.conf
WORKDIR /tmp/synfig/build
RUN /tmp/synfig/autobuild/build.sh all full



FROM base AS release
COPY --from=build /synfig /synfig
RUN groupadd -r -g 1000 justin && \
    useradd -d /home/justin -m --shell /sbin/nologin --uid 1000 -g 1000 justin
WORKDIR /home/justin
USER justin
RUN mkdir -p /home/justin/Downloads /home/justin/synfig /home/justin/art /home/justin/.config/synfig
ENTRYPOINT "/synfig/bin/synfigstudio"

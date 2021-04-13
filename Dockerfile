# docker system prune -a
# docker build -t ubuntu-focal/lxd:latest .
# docker save ubuntu-focal/lxd:latest | tar --strip-components=1 --wildcards --to-command='tar -xvf -' -xf - "*/layer.tar"

FROM ubuntu:focal AS build

ARG GO_VERSION="1.15.11"
ARG LXC_VERSION="4.0.6"
ARG LXCFS_VERSION="4.0.7"
ARG LXD_VERSION="4.13"

# ToDo: Find a way to get library versions dynamically.
ARG LIBDQLITE_SO_VERSION="0.0.1"
ARG LIBRAFT_SO_VERSION="0.0.7"
ARG LIBLXC_SO_VERSION="1.7.0"

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="${PATH}:/usr/local/go/bin"

RUN apt-get update && apt-get -y install \
  acl \
  autoconf \
  build-essential \
  bzr \
  checkinstall \
  chrpath \
  curl \
  debhelper \
  devscripts \
  dh-systemd  \
  dnsmasq-base \
  docbook2x \
  doxygen \
  dpkg-dev \
  ebtables \
  gettext \
  git \
  help2man \
  jq \
  libacl1-dev \
  libapparmor-dev \
  libattr1-dev \
  libcap-dev \
  libfuse-dev \
  libgnutls28-dev \
  liblua5.2-dev \
  libpam0g-dev \
  libseccomp-dev \
  libselinux-dev \
  libsqlite3-dev \
  libtool \
  libudev-dev \
  libuv1-dev \
  linux-libc-dev \
  lvm2 \
  make \
  patchelf \
  pkg-config \
  rsync \
  socat \
  sqlite3 \
  squashfs-tools \
  tar \
  tcl \
  thin-provisioning-tools \
  uuid-runtime \
  wget \
  xz-utils

RUN wget https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz -O /root/go$GO_VERSION.linux-amd64.tar.gz && \
  tar xvzf /root/go$GO_VERSION.linux-amd64.tar.gz -C /usr/local
RUN wget https://github.com/lxc/lxc/archive/lxc-$LXC_VERSION.tar.gz -O /root/lxc-$LXC_VERSION.tar.gz && \
  mkdir -p /root/lxc && \
  tar xvzf /root/lxc-$LXC_VERSION.tar.gz --strip-components=1 -C /root/lxc
RUN wget https://github.com/lxc/lxcfs/archive/lxcfs-$LXCFS_VERSION.tar.gz -O /root/lxcfs-$LXCFS_VERSION.tar.gz && \
  mkdir -p /root/lxcfs && \
  tar xvzf /root/lxcfs-$LXCFS_VERSION.tar.gz --strip-components=1 -C /root/lxcfs
RUN wget https://github.com/lxc/lxd/releases/download/lxd-$LXD_VERSION/lxd-$LXD_VERSION.tar.gz -O /root/lxd-$LXD_VERSION.tar.gz && \
  mkdir -p /root/lxd && \
  tar xvzf /root/lxd-$LXD_VERSION.tar.gz --strip-components=1 -C /root/lxd

RUN cd /root/lxc && \
  ./autogen.sh && \
  ./configure \
    --prefix=/usr \
    --libdir=/usr/lib/lxc \
    --disable-api-docs \
    --disable-bash \
    --disable-commands \
    --disable-doc \
    --disable-examples \
    --disable-memfd-rexec \
    --disable-mutex-debugging \
    --disable-pam \
    --disable-rpath \
    --disable-selinux \
    --disable-static \
    --disable-tests \
    --disable-tools \
    --enable-apparmor \
    --enable-capabilities \
    --enable-configpath-log \
    --enable-seccomp \
    --with-rootfs-path=/usr/lib/lxc/rootfs \
    --with-distro=ubuntu \
    --with-init-script=systemd \
    --with-pamdir=/usr/lib/x86_64-linux-gnu/ \
    --with-systemdsystemunitdir=/lib/systemd/system && \
  make && make install && \
  cp -a /usr/lib/lxc/pkgconfig/lxc.pc /usr/lib/pkgconfig/lxc.pc

RUN cd /root/lxcfs && \
  ./bootstrap.sh && \
  ./configure \
    --prefix=/usr \
    --disable-static \
    --with-rootfs-path=/usr/lib/lxc/rootfs \
    --with-distro=ubuntu \
    --with-init-script=systemd && \
  make

ENV GOPATH=/root/lxd/_dist
RUN cd ${GOPATH}/src/github.com/lxc/lxd && \
  make deps

ENV CGO_CFLAGS="-I${GOPATH}/deps/raft/include/ -I${GOPATH}/deps/dqlite/include/"
ENV CGO_LDFLAGS="-L${GOPATH}/deps/raft/.libs -L${GOPATH}/deps/dqlite/.libs/"
ENV LD_LIBRARY_PATH="${GOPATH}/deps/raft/.libs/:${GOPATH}/deps/dqlite/.libs/"
ENV CGO_LDFLAGS_ALLOW="-Wl,-wrap,pthread_create"

RUN cd ${GOPATH}/src/github.com/lxc/lxd && \
  make

RUN mkdir -v -p /BUILD/overlay/usr/bin \
    /BUILD/overlay/usr/lib/lxc \
    /BUILD/overlay/usr/lib/lxcfs \
    /BUILD/overlay/usr/lib/lxd \
    /BUILD/overlay/usr/share/bash-completion/completions && \
  cp -av $GOPATH/bin/fuidshift /BUILD/overlay/usr/bin/fuidshift && \
  cp -av $GOPATH/bin/lxc /BUILD/overlay/usr/bin/lxc && \
  cp -av $GOPATH/bin/lxd /BUILD/overlay/usr/bin/lxd && \
  cp -av $GOPATH/deps/dqlite/.libs/libdqlite.so.$LIBDQLITE_SO_VERSION /BUILD/overlay/usr/lib/lxd && \
  cp -av $GOPATH/deps/raft/.libs/libraft.so.$LIBRAFT_SO_VERSION /BUILD/overlay/usr/lib/lxd && \
  cp -av /root/lxcfs/src/.libs/liblxcfs.so /BUILD/overlay/usr/lib/lxcfs/liblxcfs.so && \
  cp -av /root/lxcfs/src/lxcfs /BUILD/overlay/usr/bin/lxcfs && \
  cp -av /usr/lib/lxc/liblxc.so.$LIBLXC_SO_VERSION /BUILD/overlay/usr/lib/lxc/liblxc.so.$LIBLXC_SO_VERSION && \
  ln -sv libdqlite.so.$LIBDQLITE_SO_VERSION /BUILD/overlay/usr/lib/lxd/libdqlite.so && \
  ln -sv libdqlite.so.$LIBDQLITE_SO_VERSION /BUILD/overlay/usr/lib/lxd/libdqlite.so.0 && \
  ln -sv liblxc.so.$LIBLXC_SO_VERSION /BUILD/overlay/usr/lib/lxc/liblxc.so && \
  ln -sv liblxc.so.$LIBLXC_SO_VERSION /BUILD/overlay/usr/lib/lxc/liblxc.so.1 && \
  ln -sv libraft.so.$LIBRAFT_SO_VERSION /BUILD/overlay/usr/lib/lxd/libraft.so && \
  ln -sv libraft.so.$LIBRAFT_SO_VERSION /BUILD/overlay/usr/lib/lxd/libraft.so.0 && \
  cp -av $GOPATH/src/github.com/lxc/lxd/scripts/bash/lxd-client /BUILD/overlay/usr/share/bash-completion/completions/lxc && \
  strip -v -s /BUILD/overlay/usr/bin/fuidshift && \
  strip -v -s /BUILD/overlay/usr/bin/lxc && \
  strip -v -s /BUILD/overlay/usr/bin/lxcfs && \
  strip -v -s /BUILD/overlay/usr/bin/lxd && \
  strip -v -s /BUILD/overlay/usr/lib/lxc/liblxc.so.$LIBLXC_SO_VERSION && \
  strip -v -s /BUILD/overlay/usr/lib/lxcfs/liblxcfs.so && \
  strip -v -s /BUILD/overlay/usr/lib/lxd/libdqlite.so.$LIBDQLITE_SO_VERSION && \
  strip -v -s /BUILD/overlay/usr/lib/lxd/libraft.so.$LIBRAFT_SO_VERSION && \
  patchelf --debug --set-rpath "/usr/lib/lxc:/usr/lib/lxd" "/BUILD/overlay/usr/bin/lxd" && \
  patchelf --debug --set-rpath "/usr/lib/lxd" "/BUILD/overlay/usr/lib/lxd/libdqlite.so" && \
  find /BUILD/overlay/ -type f -print

COPY /debian /BUILD/debian
COPY /overlay /BUILD/overlay

RUN cd /BUILD/ && \
  debuild -us -uc -b

RUN find / -name "*.deb" -maxdepth 1 -type f -print

FROM scratch
COPY --from=build /lxd_*.deb /

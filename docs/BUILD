cd ~

apt install acl autoconf build-essential bzr curl dnsmasq-base docbook2x doxygen ebtables gettext git jq libacl1-dev libapparmor-dev libcap-dev libgnutls28-dev liblua5.2-dev libpam0g-dev libseccomp-dev libselinux-dev libtool libuv1-dev linux-libc-dev lvm2 make patchelf pkg-config rsync socat sqlite3 squashfs-tools tar tcl thin-provisioning-tools uuid-runtime xz-utils

wget https://github.com/lxc/lxc/archive/lxc-3.2.1.tar.gz -O /root/lxc-3.2.1.tar.gz
tar xvzf /root/lxc-3.2.1.tar.gz -C /root/

export LXC_BUILD_DIR=/root/lxc-lxc-3.2.1

cd ${LXC_BUILD_DIR}

./autogen.sh

./configure \
	--prefix=/usr \
	--disable-api-docs \
	--disable-bash \
	--disable-doc \
	--disable-examples \
	--disable-memfd-rexec \
	--disable-mutex-debugging \
	--disable-rpath \
	--disable-tests \
	--disable-tools \
	--enable-apparmor \
	--enable-capabilities \
	--enable-configpath-log \
	--enable-seccomp \
	--enable-pam \
	--enable-selinux \
	--with-distro=debian \
	--with-init-script=sysvinit,systemd \
	--with-pamdir=/usr/lib/x86_64-linux-gnu/ \
	--with-systemdsystemunitdir=/lib/systemd/system \
	--with-rootfs-path=/var/lib/lxd/common/lxc/

make

make install

cd ~

wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz -O /root/go1.13.3.linux-amd64.tar.gz
tar xvzf /root/go1.13.3.linux-amd64.tar.gz -C /usr/local

export PATH=$PATH:/usr/local/go/bin

wget https://github.com/lxc/lxd/releases/download/lxd-3.18/lxd-3.18.tar.gz -O /root/lxd-3.18.tar.gz
tar xvzf /root/lxd-3.18.tar.gz -C /root/

export GOPATH=/root/lxd-3.18/_dist

cd $GOPATH/src/github.com/lxc/lxd
make deps

export CGO_CFLAGS="-I${GOPATH}/deps/sqlite/ -I${GOPATH}/deps/libco/ -I${GOPATH}/deps/raft/include/ -I${GOPATH}/deps/dqlite/include/"
export CGO_LDFLAGS="-L${GOPATH}/deps/sqlite/.libs/ -L${GOPATH}/deps/libco/ -L${GOPATH}/deps/raft/.libs -L${GOPATH}/deps/dqlite/.libs/"
export LD_LIBRARY_PATH="${GOPATH}/deps/sqlite/.libs/:${GOPATH}/deps/libco/:${GOPATH}/deps/raft/.libs/:${GOPATH}/deps/dqlite/.libs/"

wget https://raw.githubusercontent.com/s3rj1k/lxd-repack/master/docs/patches/0001-lxd-Add-temporary-variable-to-disable-shiftfs.patch

patch -p1 < 0001-lxd-Add-temporary-variable-to-disable-shiftfs.patch

make

mkdir -p /root/lxd_distr/usr/bin

cp -a $GOPATH/bin/fuidshift /root/lxd_distr/usr/bin/fuidshift
cp -a $GOPATH/bin/lxc /root/lxd_distr/usr/bin/lxc
cp -a $GOPATH/bin/lxd /root/lxd_distr/usr/bin/lxd
cp -a $GOPATH/bin/lxd-benchmark /root/lxd_distr/usr/bin/lxd-benchmark

patchelf --set-rpath "/usr/lib/lxd" "/root/lxd_distr/usr/bin/lxd"

mkdir -p /root/lxd_distr/usr/lib/lxd

cp -a $GOPATH/deps/dqlite/.libs/libdqlite.so.0.0.1 /root/lxd_distr/usr/lib/lxd
ln -s libdqlite.so.0.0.1 /root/lxd_distr/usr/lib/lxd/libdqlite.so.0
ln -s libdqlite.so.0.0.1 /root/lxd_distr/usr/lib/lxd/libdqlite.so

cp -a $GOPATH/deps/libco/libco.so.0.1.0 /root/lxd_distr/usr/lib/lxd
ln -s libco.so.0.1.0 /root/lxd_distr/usr/lib/lxd/libco.so
ln -s libco.so.0.1.0 /root/lxd_distr/usr/lib/lxd/libco.so.0

cp -a $GOPATH/deps/raft/.libs/libraft.so.0.0.7 /root/lxd_distr/usr/lib/lxd
ln -s libco.so.0.1.0 /root/lxd_distr/usr/lib/lxd/libraft.so.0
ln -s libco.so.0.1.0 /root/lxd_distr/usr/lib/lxd/libraft.so

cp -a $GOPATH/deps/sqlite/.libs/libsqlite3.so.0.8.6 /root/lxd_distr/usr/lib/lxd
ln -s libsqlite3.so.0.8.6 /root/lxd_distr/usr/lib/lxd/libsqlite3.so.0
ln -s libsqlite3.so.0.8.6 /root/lxd_distr/usr/lib/lxd/libsqlite3.so

cp -a /usr/lib/liblxc.so.1.6.0 /root/lxd_distr/usr/lib/lxd/liblxc.so.1.6.0
ln -s liblxc.so.1.6.0 /root/lxd_distr/usr/lib/lxd/liblxc.so.1
ln -s liblxc.so.1.6.0 /root/lxd_distr/usr/lib/lxd/liblxc.so

patchelf --set-rpath "/usr/lib/lxd" "/root/lxd_distr/usr/lib/lxd/libdqlite.so"

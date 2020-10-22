cd /root

apt-get install acl autoconf build-essential bzr checkinstall chrpath curl dnsmasq-base docbook2x doxygen ebtables gettext git help2man jq libacl1-dev libapparmor-dev libattr1-dev libcap-dev libfuse-dev libgnutls28-dev liblua5.2-dev libpam0g-dev libseccomp-dev libselinux-dev libsqlite3-dev libtool libuv1-dev linux-libc-dev lvm2 make patchelf pkg-config rsync socat sqlite3 squashfs-tools tar tcl thin-provisioning-tools uuid-runtime xz-utils libudev-dev

wget https://github.com/lxc/lxc/archive/lxc-4.0.4.tar.gz -O /root/lxc-4.0.4.tar.gz
tar xvzf /root/lxc-4.0.4.tar.gz -C /root/
export LXC_BUILD_DIR=/root/lxc-lxc-4.0.4

cd ${LXC_BUILD_DIR}

./autogen.sh
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
	--with-systemdsystemunitdir=/lib/systemd/system

make
make install
cp /usr/lib/lxc/pkgconfig/lxc.pc /usr/lib/pkgconfig/lxc.pc
# checkinstall make install

cd /root

wget https://github.com/lxc/lxcfs/archive/lxcfs-4.0.5.tar.gz -O /root/lxcfs-4.0.5.tar.gz
mkdir -p /root/lxcfs-4.0.5
tar xvzf /root/lxcfs-4.0.5.tar.gz --strip-components=1 -C /root/lxcfs-4.0.5

cd /root/lxcfs-4.0.5

./bootstrap.sh
./configure \
	--prefix=/usr \
	--disable-static \
	--with-rootfs-path=/usr/lib/lxc/rootfs \
	--with-distro=ubuntu \
	--with-init-script=systemd

make
# checkinstall make install

cd /root

wget https://dl.google.com/go/go1.14.8.linux-amd64.tar.gz -O /root/go1.14.8.linux-amd64.tar.gz
tar xvzf /root/go1.14.8.linux-amd64.tar.gz -C /usr/local
export PATH=$PATH:/usr/local/go/bin

wget https://github.com/lxc/lxd/releases/download/lxd-4.3/lxd-4.3.tar.gz -O /root/lxd-4.3.tar.gz
tar xvzf /root/lxd-4.3.tar.gz -C /root/
export GOPATH=/root/lxd-4.3/_dist

cd $GOPATH/src/github.com/lxc/lxd
make deps

export CGO_CFLAGS="-I${GOPATH}/deps/sqlite/ -I${GOPATH}/deps/libco/ -I${GOPATH}/deps/raft/include/ -I${GOPATH}/deps/dqlite/include/"
export CGO_LDFLAGS="-L${GOPATH}/deps/sqlite/.libs/ -L${GOPATH}/deps/libco/ -L${GOPATH}/deps/raft/.libs -L${GOPATH}/deps/dqlite/.libs/"
export LD_LIBRARY_PATH="${GOPATH}/deps/sqlite/.libs/:${GOPATH}/deps/libco/:${GOPATH}/deps/raft/.libs/:${GOPATH}/deps/dqlite/.libs/"
export CGO_LDFLAGS_ALLOW="-Wl,-wrap,pthread_create"

make

mkdir -p /root/lxd_distr/usr/bin /root/lxd_distr/usr/lib/lxd /root/lxd_distr/usr/lib/lxc /root/lxd_distr/usr/lib/lxcfs /root/lxd_distr/usr/share/bash-completion/completions

cp -a $GOPATH/bin/fuidshift /root/lxd_distr/usr/bin/fuidshift
cp -a $GOPATH/bin/lxc /root/lxd_distr/usr/bin/lxc
cp -a $GOPATH/bin/lxd /root/lxd_distr/usr/bin/lxd
cp -a /root/lxcfs-4.0.5/src/lxcfs /root/lxd_distr/usr/bin/lxcfs

cp -a $GOPATH/deps/dqlite/.libs/libdqlite.so.0.0.1 /root/lxd_distr/usr/lib/lxd
ln -s libdqlite.so.0.0.1 /root/lxd_distr/usr/lib/lxd/libdqlite.so.0
ln -s libdqlite.so.0.0.1 /root/lxd_distr/usr/lib/lxd/libdqlite.so

cp -a $GOPATH/deps/raft/.libs/libraft.so.0.0.7 /root/lxd_distr/usr/lib/lxd
ln -s libraft.so.0.0.7 /root/lxd_distr/usr/lib/lxd/libraft.so.0
ln -s libraft.so.0.0.7 /root/lxd_distr/usr/lib/lxd/libraft.so

cp -a /usr/lib/lxc/liblxc.so.1.7.0 /root/lxd_distr/usr/lib/lxc/liblxc.so.1.7.0
ln -s liblxc.so.1.7.0 /root/lxd_distr/usr/lib/lxc/liblxc.so.1
ln -s liblxc.so.1.7.0 /root/lxd_distr/usr/lib/lxc/liblxc.so

cp -a /root/lxcfs-4.0.5/src/.libs/liblxcfs.so /root/lxd_distr/usr/lib/lxcfs/liblxcfs.so

cat $GOPATH/src/github.com/lxc/lxd/scripts/bash/lxd-client > /root/lxd_distr/usr/share/bash-completion/completions/lxc

strip -s /root/lxd_distr/usr/lib/lxcfs/liblxcfs.so
strip -s /root/lxd_distr/usr/lib/lxd/libraft.so.0.0.7
strip -s /root/lxd_distr/usr/lib/lxd/libdqlite.so.0.0.1
strip -s /root/lxd_distr/usr/lib/lxc/liblxc.so.1.7.0
strip -s /root/lxd_distr/usr/bin/fuidshift
strip -s /root/lxd_distr/usr/bin/lxcfs
strip -s /root/lxd_distr/usr/bin/lxd
strip -s /root/lxd_distr/usr/bin/lxc

patchelf --set-rpath "/usr/lib/lxc:/usr/lib/lxd" "/root/lxd_distr/usr/bin/lxd"
patchelf --set-rpath "/usr/lib/lxd" "/root/lxd_distr/usr/lib/lxd/libdqlite.so"

# If you want to disable hidepid on /proc inside CT, remove hidepid=2 mount option in overlay/usr/share/lxcfs/lxc.mount.hook:
# mount -o remount,rw,nosuid,nodev,noexec,relatime,hidepid=2 ${LXC_ROOTFS_MOUNT}/proc

# When systemd applies sysctl, no vlans have been created yet.
# If you want to use vlan interfaces on LXD node:
# mkdir -p /etc/systemd/system/lxd.service.d
# cat <<EOF > /etc/systemd/system/lxd.service.d/override.conf
# [Service]
# ExecStartPre=/usr/sbin/sysctl --system
# EOF

FROM centos:8

RUN dnf update -y
RUN dnf install git make automake gcc gcc-c++ python3 wget -y

# for linux_config
RUN git clone https://github.com/clachan/virtplat.git /virtplat
WORKDIR /virtplat

# qemu
RUN dnf install bzip2 glib2-devel zlib-devel pixman-devel -y
RUN git clone -b stable-5.0 https://github.com/qemu/qemu
RUN cd qemu && \
    git submodule update --init && \
    ./configure --target-list=x86_64-softmmu && \
    make -j $(getconf _NPROCESSORS_ONLN)

# edk2
RUN dnf install libuuid-devel acpica-tools python36-devel -y
RUN dnf --repo powertools install nasm -y
RUN git clone -b stable/202011 https://github.com/tianocore/edk2
RUN cd edk2 && \
    git submodule update --init && \
    source ./edksetup.sh && \
    make -C $EDK_TOOLS_PATH -j $(getconf _NPROCESSORS_ONLN) && \
    build -a IA32 -a X64 -p OvmfPkg/OvmfPkgIa32X64.dsc \
      -D SMM_REQUIRE -D SECURE_BOOT_ENABLE \
      -D HTTP_BOOT_ENABLE -D TLS_ENABLE \
      -t GCC5 \
      -b DEBUG \
      -n $(getconf _NPROCESSORS_ONLN)

# linux
RUN dnf install flex bison openssl-devel elfutils-libelf-devel bc -y
RUN git clone https://github.com/torvalds/linux.git
RUN cd linux && \
    git checkout v5.12-rc6 && \
    scripts/kconfig/merge_config.sh arch/x86/configs/x86_64_defconfig ../linux_config/* && \
    make ARCH=x86_64 bzImage -j $(getconf _NPROCESSORS_ONLN)

# busybox
RUN dnf install perl-Pod-Html -y
RUN dnf --repo powertools install glibc-static -y
RUN git clone -b 1_33_stable https://github.com/mirror/busybox.git
RUN cd busybox && \
    make defconfig && \
    sed "/CONFIG_STATIC is not set/s/.*/CONFIG_STATIC=y/" -i .config && \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    make install

# obtain Fedora cloud image
RUN mkdir rootfs
RUN cd rootfs && \
    wget https://download.fedoraproject.org/pub/fedora/linux/releases/33/Cloud/x86_64/images/Fedora-Cloud-Base-33-1.2.x86_64.raw.xz && \
    xz -d Fedora-Cloud-Base-33-1.2.x86_64.raw.xz

# initramfs
RUN cd rootfs && \
    mkdir -p initramfs/{bin,sbin,etc,proc,sys,dev,usr/{bin,sbin}} && \
    cd initramfs && \
    cp -a ../../busybox/_install/* . && \
    printf '#!/bin/sh\n\
mount -t proc none /proc\n\
mount -t sysfs none /sys\n\
mdev -s\n\
\n\
ip link set eth0 up\n\
udhcpc -i eth0 -s /etc/simple.script\n\
\n\
mkdir /dev/pts\n\
mount -t devpts none /dev/pts\n\
\n\
exec /bin/sh' > ./init && \
    chmod +x ./init && \
    wget https://git.busybox.net/busybox/plain/examples/udhcp/simple.script -O etc/simple.script && \
    chmod +x etc/simple.script && \
    find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

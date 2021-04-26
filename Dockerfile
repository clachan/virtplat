FROM centos:8

RUN dnf update -y
RUN dnf install git make automake gcc gcc-c++ python3 wget -y

RUN mkdir -p /virtplat
WORKDIR /virtplat

# qemu
RUN dnf install bzip2 glib2-devel zlib-devel pixman-devel -y
RUN git clone -b stable-5.0 --single-branch --depth 1 https://github.com/qemu/qemu
RUN cd qemu && \
    git submodule update --init && \
    ./configure --target-list=x86_64-softmmu && \
    make -j $(getconf _NPROCESSORS_ONLN)

# edk2
RUN dnf install libuuid-devel acpica-tools python36-devel -y
RUN dnf --repo powertools install nasm -y
RUN git clone --branch edk2-stable202102 --single-branch --depth 1 https://github.com/tianocore/edk2
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
RUN mkdir linux_config
COPY ./linux_config/* ./linux_config/
RUN dnf install flex bison openssl-devel elfutils-libelf-devel bc -y
RUN dnf --repo powertools install dwarves -y
RUN git clone -b v5.12 --single-branch --depth 1 https://github.com/torvalds/linux.git
RUN cd linux && \
    scripts/kconfig/merge_config.sh arch/x86/configs/x86_64_defconfig ../linux_config/* && \
    make ARCH=x86_64 bzImage -j $(getconf _NPROCESSORS_ONLN) && \
    make scripts_gdb

# busybox
RUN dnf install perl-Pod-Html -y
RUN dnf --repo powertools install glibc-static -y
RUN git clone -b 1_33_stable --single-branch --depth 1 https://github.com/mirror/busybox.git
RUN cd busybox && \
    make defconfig && \
    sed "/CONFIG_STATIC is not set/s/.*/CONFIG_STATIC=y/" -i .config && \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    make install

# initramfs
RUN mkdir rootfs && \
    cd rootfs && \
    mkdir -p initramfs/{bin,sbin,etc,proc,sys,dev,usr/{bin,sbin}}
COPY ./initramfs-init rootfs/initramfs/init
COPY ./dhcp.script rootfs/initramfs/etc/dhcp.script
RUN cd rootfs/initramfs && \
    cp -a ../../busybox/_install/* . && \
    chmod +x init && \
    chmod +x etc/dhcp.script && \
    find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

# fetch ubuntu cloud image
RUN wget https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64.img \
    -O rootfs/ubuntu-20.04-server-cloudimg-amd64.img -q

# install cgdb
RUN dnf install epel-release -y
RUN dnf install cgdb -y

# add start scripts
ADD ./start_qemu.sh .
ADD ./start_uefi_shell.sh .
ADD ./debug_uefi_shell.sh .
ADD ./debug_linux.sh .

# add hda-contents for UEFI Shell
RUN mkdir -p hda-contents
RUN cd hda-contents && \
    ln -s ../linux/arch/x86/boot/bzImage && \
    ln -s ../rootfs/initramfs.cpio.gz

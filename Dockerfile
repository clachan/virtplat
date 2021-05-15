FROM centos:8

RUN dnf update -y
RUN dnf install git make automake gcc gcc-c++ python3 wget -y

WORKDIR /virtplat

# qemu
RUN dnf install bzip2 glib2-devel zlib-devel pixman-devel -y
RUN pip3 install ninja
RUN cd src/qemu && \
    ./configure --target-list=x86_64-softmmu && \
    make -j $(getconf _NPROCESSORS_ONLN)

# edk2
RUN dnf install libuuid-devel acpica-tools python3-devel llvm llvm-devel clang lld -y
RUN dnf --repo powertools install nasm -y
RUN cd src/edk2 && \
    source ./edksetup.sh && \
    make -C $EDK_TOOLS_PATH -j $(getconf _NPROCESSORS_ONLN) && \
    build -a IA32 -a X64 -p OvmfPkg/OvmfPkgIa32X64.dsc \
      -D SMM_REQUIRE -D SECURE_BOOT_ENABLE \
      -D HTTP_BOOT_ENABLE -D TLS_ENABLE \
      -t CLANGPDB \
      -b DEBUG \
      -n $(getconf _NPROCESSORS_ONLN)

# linux
RUN dnf install flex bison openssl-devel elfutils-libelf-devel bc -y
RUN dnf --repo powertools install dwarves -y
RUN cd src/linux && \
    make mrproper && \
    scripts/kconfig/merge_config.sh arch/x86/configs/x86_64_defconfig ../../linux_config/* && \
    make ARCH=x86_64 LLVM=1 bzImage -j $(getconf _NPROCESSORS_ONLN) && \
    make LLVM=1 scripts_gdb

# busybox
RUN dnf install perl-Pod-Html -y
RUN dnf --repo powertools install glibc-static -y
RUN cd src/busybox && \
    make defconfig && \
    sed "/CONFIG_STATIC is not set/s/.*/CONFIG_STATIC=y/" -i .config && \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    make install

# initramfs
RUN mkdir -p rootfs && \
    cd rootfs && \
    mkdir -p initramfs/{bin,sbin,etc,proc,sys,dev,usr/{bin,sbin}}
COPY ./initramfs-init rootfs/initramfs/init
COPY ./dhcp.script rootfs/initramfs/etc/dhcp.script
RUN cd rootfs/initramfs && \
    cp -a ../../src/busybox/_install/* . && \
    chmod +x init && \
    chmod +x etc/dhcp.script && \
    find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz

# fetch ubuntu cloud image
#RUN wget https://cloud-images.ubuntu.com/releases/hirsute/release/ubuntu-21.04-server-cloudimg-amd64.img \
#    -O rootfs/ubuntu-21.04-server-cloudimg-amd64.img

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
    ln -sf ../src/linux/arch/x86/boot/bzImage && \
    ln -sf ../rootfs/initramfs.cpio.gz

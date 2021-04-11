#!/bin/bash

qemu/x86_64-softmmu/qemu-system-x86_64 \
    -kernel linux/arch/x86/boot/bzImage \
    -append "console=ttyS0 nokaslr" \
    -initrd rootfs/initramfs.cpio.gz \
    -blockdev driver=file,filename=edk2/Build/Ovmf3264/DEBUG_GCC5/FV/OVMF_CODE.fd,node-name=libvirt-pflash0-storage,auto-read-only=on,discard=unmap \
    -blockdev node-name=libvirt-pflash0-format,read-only=on,driver=raw,file=libvirt-pflash0-storage \
    -blockdev driver=file,filename=edk2/Build/Ovmf3264/DEBUG_GCC5/FV/OVMF_VARS.fd,node-name=libvirt-pflash1-storage,auto-read-only=on,discard=unmap \
    -blockdev node-name=libvirt-pflash1-format,read-only=on,driver=raw,file=libvirt-pflash1-storage \
    -machine pc-q35-5.0,smm=on,pflash0=libvirt-pflash0-format,pflash1=libvirt-pflash1-format \
    -cpu Icelake-Server \
    -m 16384M \
    -netdev user,id=user.0 -device virtio-net-pci,netdev=user.0 \
    -drive file=rootfs/ubuntu-20.04-server-cloudimg-amd64.img \
    -enable-kvm \
    -nographic \
    -s

#!/bin/bash

qemu/x86_64-softmmu/qemu-system-x86_64 \
    -blockdev driver=file,filename=edk2/Build/Ovmf3264/DEBUG_GCC5/FV/OVMF_CODE.fd,node-name=libvirt-pflash0-storage,auto-read-only=on,discard=unmap \
    -blockdev node-name=libvirt-pflash0-format,read-only=on,driver=raw,file=libvirt-pflash0-storage \
    -blockdev driver=file,filename=edk2/Build/Ovmf3264/DEBUG_GCC5/FV/OVMF_VARS.fd,node-name=libvirt-pflash1-storage,auto-read-only=on,discard=unmap \
    -blockdev node-name=libvirt-pflash1-format,read-only=on,driver=raw,file=libvirt-pflash1-storage \
    -machine pc-q35-5.0,smm=on,pflash0=libvirt-pflash0-format,pflash1=libvirt-pflash1-format \
    -cpu Icelake-Server \
    -m 16384M \
    -enable-kvm \
    -nographic \
    -hda fat:rw:hda-contents \
    -net none \
    -debugcon file:ovmf-debug.log -global isa-debugcon.iobase=0x402 \
    -s

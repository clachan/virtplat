#!/bin/bash

mkdir -p src
cd src

git clone -b v6.0.0 --single-branch --depth 1 https://github.com/qemu/qemu
cd qemu && git submodule update --init && cd ..

git clone --branch edk2-stable202102 --single-branch --depth 1 https://github.com/tianocore/edk2
cd edk2 && git submodule update --init && cd ..

git clone -b v5.12 --single-branch --depth 1 https://github.com/torvalds/linux.git

git clone -b 1_33_stable --single-branch --depth 1 https://github.com/mirror/busybox.git

cd ..
mkdir -p rootfs
wget https://cloud-images.ubuntu.com/releases/hirsute/release/ubuntu-21.04-server-cloudimg-amd64.img \
  -O rootfs/ubuntu-21.04-server-cloudimg-amd64.img

# virtplat
My QEMU-based virtual platform setup

## How to build

```shell
git clone https://github.com/clachan/virtplat
podman build --tag virtplat --jobs 32 .
```

## How to use

```shell
podman run -it --rm --privileged --name my_virtplat virtplat
./start_qemu.sh
```
or
```shell
./build.sh
```

## How to debug kernel

Open another terminal to connect to my_virtplat
```shell
podman exec -it my_virtplat /bin/bash
```
or
```shell
./run.sh
```
then run
```shell
./start_qemu.sh
```
to start qemu.

If you want to use Ubuntu as the root file system (2nd stage), type:
```shell
./start_qemu.sh virtplat_rootfs=ubuntu
```

Start gdb
```shell
./debug_linux.sh
```

Set breakpoint and happy debugging!

## Quick Notes

* Add nokaslr kernel option

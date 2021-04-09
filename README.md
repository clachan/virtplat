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
```

## How to debug kernel

Open another terminal to connect to my_virtplat
```shell
docker exec -it my_virtplat /bin/bash
```

Install gdb
```shell
dnf install gdb
```

Start gdb
```shell
gdb linux/vmlinux
```

Set breakpoint and happy debugging!

## Quick Notes

* Add nokaslr kernel option

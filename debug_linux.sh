#!/bin/bash

cat << EOF > /tmp/.gdb.linux.init
set auto-load safe-path /
set directories linux
file linux/vmlinux
source linux/vmlinux-gdb.py
target remote :1234
EOF

cgdb -x /tmp/.gdb.linux.init

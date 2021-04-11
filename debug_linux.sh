#!/bin/bash

cat << EOF > /tmp/.gdb.linux.init
target remote :1234
file linux/vmlinux
source linux/vmlinux-gdb.py
EOF

cgdb -x /tmp/.gdb.linux.init

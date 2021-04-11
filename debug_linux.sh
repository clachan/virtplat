#!/bin/bash

cat << EOF > /tmp/.gdbinit.linux
set auto-load-safe-path linux/scripts/gdb/vmlinux-gdb.py
set directories linux
file linux/vmlinux
source linux/vmlinux-gdb.py
target remote :1234
EOF

cgdb -x /tmp/.gdbinit.linux

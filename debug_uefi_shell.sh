#!/bin/bash

cat << EOF > /tmp/.gdb.uefi.init
source uefi-gdb/efi.py
efi -r -64
EOF

cgdb -x /tmp/.gdb.uefi.init

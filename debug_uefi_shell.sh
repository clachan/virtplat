#!/bin/bash

cat << EOF > /tmp/.gdbinit.uefi
source uefi-gdb/efi.py
efi -r -64
EOF

cgdb -x /tmp/.gdbinit.uefi

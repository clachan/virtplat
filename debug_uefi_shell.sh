#!/bin/bash

cat << EOF > /tmp/.gdbinit.uefi
add directories edk2
source uefi-gdb/efi.py
efi -r -64
EOF

cgdb -x /tmp/.gdbinit.uefi

#!/bin/bash
# Runs INSIDE the MadOS custom-root via systemd-nspawn.
# Rebuilds the initramfs from the (now clean) casper scripts tree.
set -x
ls /usr/share/initramfs-tools/scripts/casper-bottom/ | grep 15auto
update-initramfs -u -k 7.0.0-42-generic
echo MADOS-INITRD-REBUILT

#!/bin/bash
# Rebuild the Cubic project skeleton from the Mint 22.3 ISO (classic layout).
exec > /root/mados-extract-mint.log 2>&1
set -x
ISO=/home/maddie/isos/linuxmint-22.3-cinnamon-64bit.iso
PROJ=/home/maddie/MadOS-Cubic
rm -rf "$PROJ/custom-live" "$PROJ/custom-root"
mkdir -p "$PROJ/custom-live" "$PROJ/custom-root" /mnt/iso-ro
mount -o loop,ro "$ISO" /mnt/iso-ro
cp -a /mnt/iso-ro/. "$PROJ/custom-live/"
echo "=== .disk/info:"; cat "$PROJ/custom-live/.disk/info" 2>/dev/null
echo "=== casper layout:"; ls "$PROJ/custom-live/casper/"
echo "=== volume id:"; blkid -o value -s LABEL "$ISO"
/usr/share/cubic/commands/extract-root "$PROJ/custom-live/casper/filesystem.squashfs" "$PROJ/custom-root"
umount /mnt/iso-ro
ls "$PROJ/custom-root" | head
du -sh "$PROJ/custom-live" "$PROJ/custom-root"
df -h / | tail -1
echo EXTRACT-MINT-DONE

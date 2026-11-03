#!/bin/bash
# Runs INSIDE the MadOS custom-root via systemd-nspawn.
# Teaches casper's 15autologin to recognise Plasma's Wayland session file,
# so live boots write Session=plasma.desktop into /etc/sddm.conf.
set -x
F=/usr/share/initramfs-tools/scripts/casper-bottom/15autologin
cp -a "$F" "$F.mados-backup"
sed -i 's|/root/usr/share/xsessions/plasma.desktop|/root/usr/share/wayland-sessions/plasma.desktop|' "$F"
grep -n 'wayland-sessions/plasma' "$F"
# The hand-rolled sddm drop-in is superseded by the casper route; remove it
# so there is exactly one source of truth for live autologin.
rm -f /etc/sddm.conf.d/mados-live.conf
# Rebuild the initramfs so the patched casper script is the one that runs.
update-initramfs -u -k 7.0.0-42-generic
ls -la /boot/
echo MADOS-CASPER-FIX-DONE

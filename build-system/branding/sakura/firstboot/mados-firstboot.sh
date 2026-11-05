#!/bin/bash
# =============================================================================
# MadOS first-boot setup (installed systems only).
#
# Runs ONCE, as root, before the display manager on the first boot of
# a machine installed from the MadOS ISO. Most of sakura-system.sh is
# static and is baked into the ISO by build-system/iso/stage-system.sh,
# but two pieces need the username the installer created, which does
# not exist when the ISO is built:
#   - the manual login (HideUsers=<user>, autologin stripped)
#   - the system avatar (AccountsService icon for that user)
# So this runner finds the first human user and runs the proven
# sakura-system.sh for them; the script is idempotent, so its static
# parts simply re-confirm what the image already carries. A marker
# file (+ the unit disabling itself) keeps it to exactly one run.
# Log: /var/log/mados-firstboot.log
# =============================================================================
set -u
MARKER=/var/lib/mados-firstboot-done
[ -e "$MARKER" ] && exit 0

U="$(getent passwd | awk -F: '$3 >= 1000 && $3 < 60000 {print $1; exit}')"
if [ -z "$U" ]; then
  U="$(ls /home 2>/dev/null | head -n 1)"
fi

if [ -n "$U" ] && [ -f /usr/share/mados/sakura/sakura-system.sh ]; then
  SUDO_USER="$U" bash /usr/share/mados/sakura/sakura-system.sh \
    >> /var/log/mados-firstboot.log 2>&1 || true
fi

mkdir -p /var/lib
touch "$MARKER"
systemctl disable mados-firstboot.service >/dev/null 2>&1 || true
exit 0

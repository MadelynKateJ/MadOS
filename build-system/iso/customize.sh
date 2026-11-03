#!/bin/bash
# Host-side runner: stage payload into custom-root, customize via systemd-nspawn.
exec > /root/mados-customize-run.log 2>&1
set -x
ROOT=/home/maddie/MadOS-Cubic/custom-root
SRC=/home/maddie/MadOS-src
mkdir -p "$ROOT/tmp/mados-debs"
cp "$SRC/mados-desktop.deb" \
   "$SRC/mados_core/mados-core.deb" \
   "$SRC/mados-ui/mados-ui.deb" \
   "$SRC/mados-settings/mados-settings.deb" \
   "$SRC/mados-update/mados-update.deb" \
   "$SRC/mados-welcome/mados-welcome.deb" \
   "$ROOT/tmp/mados-debs/"
cp /root/mados-in-root.sh "$ROOT/root/mados-in-root.sh"
chmod +x "$ROOT/root/mados-in-root.sh"
systemd-nspawn --quiet -D "$ROOT" --resolv-conf=bind-host \
  /bin/bash /root/mados-in-root.sh
echo "nspawn exit: $?"
tail -5 "$ROOT/root/mados-customize.log"
echo CUSTOMIZE-RUN-DONE

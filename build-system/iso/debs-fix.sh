#!/bin/bash
# Second pass: install Maddie's MadOS .debs into custom-root.
# (First pass staged them in /tmp, which systemd-nspawn covers with a tmpfs.)
exec > /root/mados-debs-fix.log 2>&1
set -x
ROOT=/home/maddie/MadOS-Cubic/custom-root
SRC=/home/maddie/MadOS-src
mkdir -p "$ROOT/root/mados-debs"
cp "$SRC/mados-desktop.deb" \
   "$SRC/mados_core/mados-core.deb" \
   "$SRC/mados-ui/mados-ui.deb" \
   "$SRC/mados-settings/mados-settings.deb" \
   "$SRC/mados-update/mados-update.deb" \
   "$SRC/mados-welcome/mados-welcome.deb" \
   "$ROOT/root/mados-debs/"
cat > "$ROOT/root/mados-debs-in.sh" <<'EOS'
#!/bin/bash
exec > /root/mados-debs-in.log 2>&1
set -x
export DEBIAN_FRONTEND=noninteractive
apt-get install -y /root/mados-debs/*.deb
mkdir -p /usr/share/mados/debs
cp /root/mados-debs/*.deb /usr/share/mados/debs/
apt-get clean
echo "--- installed mados packages:"
dpkg-query -W 'mados*' 2>/dev/null
ls /usr/bin/mados* /usr/share/mados/debs/
echo MADOS-DEBS-DONE
EOS
chmod +x "$ROOT/root/mados-debs-in.sh"
systemd-nspawn --quiet -D "$ROOT" --resolv-conf=bind-host \
  /bin/bash /root/mados-debs-in.sh
echo "nspawn exit: $?"
tail -20 "$ROOT/root/mados-debs-in.log"
echo DEBS-FIX-RUN-DONE

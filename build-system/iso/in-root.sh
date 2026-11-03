#!/bin/bash
# Runs INSIDE the MadOS custom-root (via systemd-nspawn, Cubic's own mechanism).
exec > /root/mados-customize.log 2>&1
set -x
export DEBIAN_FRONTEND=noninteractive

# --- KDE Plasma 6.8 via KDE neon (the verified recipe) -----------------------
curl -s http://archive.neon.kde.org/public.key | gpg --dearmor \
  > /usr/share/keyrings/neon-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/neon-archive-keyring.gpg] http://archive.neon.kde.org/user noble main" \
  > /etc/apt/sources.list.d/neon.list
apt-get update
apt-get -y full-upgrade
echo "sddm shared/default-x-display-manager select sddm" | debconf-set-selections
echo "/usr/bin/sddm" > /etc/X11/default-display-manager
apt-get install -y neon-desktop
echo "--- plasmashell version in image:"
QT_QPA_PLATFORM=offscreen plasmashell --version || dpkg-query -W plasma-workspace

# --- MadOS components (her own .debs) -----------------------------------------
apt-get install -y /tmp/mados-debs/*.deb
mkdir -p /usr/share/mados/debs
cp /tmp/mados-debs/*.deb /usr/share/mados/debs/

# --- Identity (branding fields only; base IDs stay Ubuntu for tooling) --------
sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="MadOS 0.1.0-alpha"/' /etc/os-release
sed -i 's/^NAME=.*/NAME="MadOS"/' /etc/os-release
sed -i 's/^VERSION=.*/VERSION="0.1.0-alpha"/' /etc/os-release
grep -q '^VERSION_CODENAME=' /etc/os-release || true

cat > /usr/share/mados/BUILD-INFO.txt <<'EOF'
MadOS 0.1.0-alpha
Base: Ubuntu 24.04.4 LTS desktop (noble)
Desktop: KDE Plasma 6.8 via KDE neon user repository
Components: mados-core, mados-ui, mados-settings, mados-update,
            mados-welcome, mados-desktop (metapackage)
Assembled in Cubic on the kde-lab VM; see project README.
EOF

apt-get clean
echo MADOS-CUSTOMIZE-DONE

#!/bin/bash
# =============================================================================
# MadOS: force-install KDE Plasma 6.8 onto an Ubuntu 24.04 (noble) base.
#
# WHERE TO RUN THIS: inside Cubic's chroot terminal (you are already root),
# on an unpacked Ubuntu 24.04 / Kubuntu 24.04 / Mint 22.x ISO. The same script
# also works on a live installed 24.04 system (VM-tested 2026-11-03, see the
# runbook). It will NOT ask questions; everything is noninteractive.
#
# WHAT IT DOES: bolts the KDE neon "user" repository onto the noble base and
# installs neon-desktop. Neon is what makes this "forcible": Plasma 6.8 needs
# Qt 6.11 and Frameworks 6.30, while stock 24.04 ships Qt 6.4 — neon replaces
# the entire Qt/KDE library stack with its own builds. That is the whole trick.
#
# EXPECT: a long package run (hundreds of packages, several GB). Occasional
# dependency noise is normal on this route; the full-upgrade BEFORE the
# desktop install is what keeps it from wedging — do not skip it.
#
# Plasma 6.8 is WAYLAND ONLY. There is no Plasma X11 session anymore;
# X11 apps ride XWayland. KWin's X11 pieces in the repo are 6.7.x leftovers.
# =============================================================================
set -x
export DEBIAN_FRONTEND=noninteractive

# --- 1. KDE neon repository (the source of Plasma 6.8 on a noble base) -------
curl -s http://archive.neon.kde.org/public.key | gpg --dearmor \
  > /usr/share/keyrings/neon-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/neon-archive-keyring.gpg] http://archive.neon.kde.org/user noble main" \
  > /etc/apt/sources.list.d/neon.list
apt-get update

# --- 2. Raise the shared libraries to neon's versions FIRST ------------------
# Installing neon-desktop without this is where the dependency fights start.
apt-get -y full-upgrade

# --- 3. Pick SDDM as display manager before it lands --------------------------
# (In a Cubic chroot this just writes config into the image; on a live system
#  it also stops the GDM-vs-SDDM coin flip during the install.)
echo "sddm shared/default-x-display-manager select sddm" | debconf-set-selections
echo "/usr/bin/sddm" > /etc/X11/default-display-manager

# --- 4. The desktop itself -----------------------------------------------------
apt-get install -y neon-desktop

# --- 5. Proof + a manifest that stays in the image -----------------------------
plasmashell --version | tee /root/kde68-version.txt
dpkg -l | grep -E 'neon|plasma|kwin|libqt6core6' > /root/kde68-manifest.txt
apt-get clean
echo "KDE68-FORCE-INSTALL-DONE — check /root/kde68-version.txt (want: plasmashell 6.8.x)"

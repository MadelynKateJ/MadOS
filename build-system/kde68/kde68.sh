#!/bin/bash
# Force-install KDE Plasma 6.8 (KDE neon stack) onto Ubuntu 24.04.
# Runs as root inside the target VM. Logs everything; stage markers inline.
exec > /root/kde68.log 2>&1
set -x
export DEBIAN_FRONTEND=noninteractive

echo "=== STAGE A: neon repo ==="
curl -s http://archive.neon.kde.org/public.key | gpg --dearmor > /usr/share/keyrings/neon-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/neon-archive-keyring.gpg] http://archive.neon.kde.org/user noble main" > /etc/apt/sources.list.d/neon.list
apt-get update -qq
echo "=== STAGE A DONE ==="

echo "=== STAGE B: full-upgrade onto neon libraries ==="
apt-get full-upgrade -y
echo "=== STAGE B DONE (rc=$?) ==="

echo "=== STAGE C: neon-desktop ==="
apt-get install -y neon-desktop
echo "=== STAGE C DONE (rc=$?) ==="

echo "=== RESULT ==="
plasmashell --version
kded6 --version 2>/dev/null | head -1
qtpaths6 --qt-version 2>/dev/null || qmake6 -v 2>/dev/null | head -2
echo "KDE68-SCRIPT-END"

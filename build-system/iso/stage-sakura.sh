#!/bin/bash
# =============================================================================
# Stage MadOS Sakura into a Cubic project's custom root, so the built
# ISO hands every new user the full theme at first login.
#
#   bash build-system/iso/stage-sakura.sh /path/to/MadOS-Cubic
#
# What lands in the image:
#   /usr/share/mados/sakura/            the whole sakura tree (this repo)
#   /usr/share/mados/first-login.sh     runs apply-sakura.sh once
#   /etc/skel/.config/autostart/        fires that runner at first login
# Nothing is applied at build time; the theme is per-user by design.
# =============================================================================
set -e
PROJ="${1:?usage: stage-sakura.sh /path/to/MadOS-Cubic}"
ROOTFS="$PROJ/custom-root"
[ -d "$ROOTFS" ] || { echo "no custom-root under $PROJ"; exit 1; }
BS="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOTFS/usr/share/mados" "$ROOTFS/etc/skel/.config/autostart"
rm -rf "$ROOTFS/usr/share/mados/sakura"
cp -r "$BS/branding/sakura" "$ROOTFS/usr/share/mados/sakura"
cp "$BS/branding/sakura/first-login-system.sh" "$ROOTFS/usr/share/mados/first-login.sh"
chmod +x "$ROOTFS/usr/share/mados/first-login.sh"
cat > "$ROOTFS/etc/skel/.config/autostart/mados-sakura.desktop" <<'DEOF'
[Desktop Entry]
Type=Application
Name=MadOS Sakura first-login setup
Exec=bash /usr/share/mados/first-login.sh
X-KDE-autostart-phase=2
NoDisplay=true
DEOF
echo "Sakura staged into $ROOTFS"

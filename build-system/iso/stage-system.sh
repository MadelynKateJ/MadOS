#!/bin/bash
# =============================================================================
# Stage the SYSTEM-level Sakura pieces into a Cubic project's custom
# root, so a machine installed from the built ISO gets the same login
# screen and boot menu as a converted one. Run AFTER stage-sakura.sh
# (it needs the sakura tree that script stages), with sudo:
#
#   sudo bash build-system/iso/stage-sakura.sh /path/to/MadOS-Cubic
#   sudo bash build-system/iso/stage-system.sh /path/to/MadOS-Cubic
#
# What lands in the image:
#   /usr/share/sddm/themes/mados/       the mados login theme (static)
#   /etc/sddm.conf.d/10-mados.conf      selects it
#   /etc/sddm.conf.d/30-novirtualkeyboard.conf   no on-screen keyboard
#   /boot/grub/themes/mados/            dusk blossoms + theme.txt
#   /etc/default/grub                   GRUB_THEME points at it, and
#   /etc/default/grub.d/                Breeze drop-ins repointed too,
#     so the installer's own update-grub produces a themed config
#   /etc/os-release                     LOGO=mados
#   /usr/share/icons/hicolor/.../apps/  mados.png + distributor-logo.png
#   /etc/systemd/system/mados-firstboot.service   enabled, runs once
#
# Two pieces cannot be baked (they need the username the installer
# creates): the manual login's HideUsers and the system avatar. The
# first-boot unit handles those on the installed machine's first
# boot by running the in-image sakura-system.sh for that user; see
# branding/sakura/firstboot/. The icon cache is refreshed there too.
# =============================================================================
set -e
PROJ="${1:?usage: stage-system.sh /path/to/MadOS-Cubic}"
ROOTFS="$PROJ/custom-root"
[ -d "$ROOTFS" ] || { echo "no custom-root under $PROJ"; exit 1; }
SK="$ROOTFS/usr/share/mados/sakura"
[ -f "$SK/sakura-system.sh" ] || {
  echo "sakura tree not staged in $ROOTFS yet - run stage-sakura.sh first"
  exit 1
}
DUSK="$SK/mados-sakura-dusk.jpg"

# --- SDDM theme (from the rootfs's own Breeze, like the live script) --------
if [ -d "$ROOTFS/usr/share/sddm/themes/breeze" ]; then
  rm -rf "$ROOTFS/usr/share/sddm/themes/mados"
  cp -r "$ROOTFS/usr/share/sddm/themes/breeze" \
        "$ROOTFS/usr/share/sddm/themes/mados"
  cp "$DUSK" "$ROOTFS/usr/share/sddm/themes/mados/background.jpg"
  if grep -q '^background=' "$ROOTFS/usr/share/sddm/themes/mados/theme.conf"; then
    sed -i 's|^background=.*|background=background.jpg|' \
      "$ROOTFS/usr/share/sddm/themes/mados/theme.conf"
  else
    echo 'background=background.jpg' \
      >> "$ROOTFS/usr/share/sddm/themes/mados/theme.conf"
  fi
  sed -i 's|^Name=.*|Name=MadOS|' \
    "$ROOTFS/usr/share/sddm/themes/mados/metadata.desktop" 2>/dev/null || true
  echo "SDDM theme baked."
fi
mkdir -p "$ROOTFS/etc/sddm.conf.d"
printf '[Theme]\nCurrent=mados\n' > "$ROOTFS/etc/sddm.conf.d/10-mados.conf"
printf '[General]\nInputMethod=\n' \
  > "$ROOTFS/etc/sddm.conf.d/30-novirtualkeyboard.conf"

# --- GRUB theme + defaults ----------------------------------------------------
mkdir -p "$ROOTFS/boot/grub/themes/mados"
cp "$DUSK" "$ROOTFS/boot/grub/themes/mados/background.jpg"
cp "$SK/grub-theme.txt" "$ROOTFS/boot/grub/themes/mados/theme.txt"
if grep -q '^GRUB_THEME=' "$ROOTFS/etc/default/grub"; then
  sed -i 's|^GRUB_THEME=.*|GRUB_THEME=/boot/grub/themes/mados/theme.txt|' \
    "$ROOTFS/etc/default/grub"
else
  echo 'GRUB_THEME=/boot/grub/themes/mados/theme.txt' \
    >> "$ROOTFS/etc/default/grub"
fi
for f in "$ROOTFS"/etc/default/grub.d/*.cfg; do
  [ -f "$f" ] || continue
  if grep -q '/boot/grub/themes/breeze/theme.txt' "$f"; then
    sed -i 's|/boot/grub/themes/breeze/theme.txt|/boot/grub/themes/mados/theme.txt|g' "$f"
    echo "Repointed ${f##*/} at the mados GRUB theme."
  fi
done
echo "GRUB theme baked."

# --- Distro logo ---------------------------------------------------------------
if grep -q '^LOGO=' "$ROOTFS/etc/os-release"; then
  sed -i 's/^LOGO=.*/LOGO=mados/' "$ROOTFS/etc/os-release"
else
  echo 'LOGO=mados' >> "$ROOTFS/etc/os-release"
fi
install -D -m644 "$SK/cat.png" \
  "$ROOTFS/usr/share/icons/hicolor/128x128/apps/mados.png"
install -D -m644 "$SK/cat.png" \
  "$ROOTFS/usr/share/icons/hicolor/128x128/apps/distributor-logo.png"

# --- First-boot unit ------------------------------------------------------------
chmod +x "$SK/firstboot/mados-firstboot.sh"
cp "$SK/firstboot/mados-firstboot.service" \
   "$ROOTFS/etc/systemd/system/mados-firstboot.service"
mkdir -p "$ROOTFS/etc/systemd/system/multi-user.target.wants"
ln -sf ../mados-firstboot.service \
  "$ROOTFS/etc/systemd/system/multi-user.target.wants/mados-firstboot.service"
echo "System pieces + first-boot staged into $ROOTFS"

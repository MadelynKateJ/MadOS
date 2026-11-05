#!/bin/bash
# =============================================================================
# MadOS system-level theming: SDDM login theme, GRUB theme, system avatar.
# The user-level Sakura pieces live in apply-sakura.sh; these three need
# root, so they are bundled here to run ONCE from a repo clone:
#
#   sudo bash build-system/branding/sakura/sakura-system.sh
#
# Uses mados-sakura-dusk.jpg and cat.png from this same folder.
# Safe to re-run.
# =============================================================================
set -e
[ "$(id -u)" = "0" ] || { echo "Run with sudo."; exit 1; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# --- SDDM: a "mados" theme = Breeze re-skinned with the dusk blossoms --------
if [ -d /usr/share/sddm/themes/breeze ]; then
  rm -rf /usr/share/sddm/themes/mados
  cp -r /usr/share/sddm/themes/breeze /usr/share/sddm/themes/mados
  cp "$HERE/mados-sakura-dusk.jpg" /usr/share/sddm/themes/mados/background.jpg
  if grep -q '^background=' /usr/share/sddm/themes/mados/theme.conf; then
    sed -i 's|^background=.*|background=background.jpg|' \
      /usr/share/sddm/themes/mados/theme.conf
  else
    echo 'background=background.jpg' >> /usr/share/sddm/themes/mados/theme.conf
  fi
  sed -i 's|^Name=.*|Name=MadOS|' /usr/share/sddm/themes/mados/metadata.desktop \
    2>/dev/null || true
  mkdir -p /etc/sddm.conf.d
  printf '[Theme]\nCurrent=mados\n' > /etc/sddm.conf.d/10-mados.conf
  echo "SDDM theme set to mados."
fi

# --- Manual login: no user list, no autologin ------------------------------
# The Breeze-based theme falls back to its "Type in Username and
# Password" form when the user model is empty (showUserList is false
# when the model count is 0 or not all users are contained). So: hide
# the installing user from the greeter, never prefill the last user,
# and strip any installer-set autologin, or no login screen appears.
U2="${SUDO_USER:-}"
if [ -n "$U2" ] && id "$U2" >/dev/null 2>&1; then
  if [ -f /etc/sddm.conf ]; then
    sed -i "/^User=${U2}\$/d; /^Session=plasma\$/d" /etc/sddm.conf
  fi
  printf '[Users]\nHideUsers=%s\nRememberLastUser=false\n' "$U2" \
    > /etc/sddm.conf.d/20-manuallogin.conf
  echo "SDDM manual login set for $U2 (no user list, no autologin)."
fi

# --- No virtual keyboard -----------------------------------------------------
# KDE neon ships /usr/lib/sddm/sddm.conf.d/00neon-virtualkbd.conf with
# InputMethod=qtvirtualkeyboard, so the greeter pops an on-screen
# keyboard even on machines with a real keyboard. An empty InputMethod
# in /etc/sddm.conf.d outranks the packaged default and loads none.
printf '[General]\nInputMethod=\n' \
  > /etc/sddm.conf.d/30-novirtualkeyboard.conf
echo "SDDM virtual keyboard disabled."

# --- GRUB: dusk blossoms behind a pink menu -----------------------------------
mkdir -p /boot/grub/themes/mados
cp "$HERE/mados-sakura-dusk.jpg" /boot/grub/themes/mados/background.jpg
cat > /boot/grub/themes/mados/theme.txt <<'EOF'
title-text: ""
desktop-image: "background.jpg"
desktop-image-scale-method: "crop"

+ boot_menu {
    left = 32%
    width = 36%
    top = 36%
    height = 34%
    item_font = "DejaVu Sans Bold 18"
    item_color = "#f9a8d4"
    item_height = 36
    item_spacing = 6
    selected_item_font = "DejaVu Sans Bold 18"
    selected_item_color = "#ffffff"
}

+ label {
    top = 84%
    width = 100%
    align = "center"
    font = "DejaVu Sans 14"
    color = "#fbcfe8"
    text = "MadOS - Surprisingly Functional"
}
EOF
if grep -q '^GRUB_THEME=' /etc/default/grub; then
  sed -i 's|^GRUB_THEME=.*|GRUB_THEME=/boot/grub/themes/mados/theme.txt|' \
    /etc/default/grub
else
  echo 'GRUB_THEME=/boot/grub/themes/mados/theme.txt' >> /etc/default/grub
fi
# Watch out: grub.d drop-ins are sourced AFTER /etc/default/grub, so a
# stock Breeze drop-in (99_breeze-grub.cfg, shipped with KDE neon) gets
# the last word and silently restores the Breeze theme. Repoint any
# drop-in that still names the Breeze theme at the MadOS one.
for f in /etc/default/grub.d/*.cfg; do
  [ -f "$f" ] || continue
  if grep -q '/boot/grub/themes/breeze/theme.txt' "$f"; then
    sed -i 's|/boot/grub/themes/breeze/theme.txt|/boot/grub/themes/mados/theme.txt|g' "$f"
    echo "Repointed $f at the mados GRUB theme."
  fi
done
update-grub || grub-mkconfig -o /boot/grub/grub.cfg
echo "GRUB theme set to mados."

# --- System avatar (AccountsService) ------------------------------------------
U="${SUDO_USER:-}"
if [ -n "$U" ] && id "$U" >/dev/null 2>&1; then
  mkdir -p /var/lib/AccountsService/icons /var/lib/AccountsService/users
  cp "$HERE/cat.png" "/var/lib/AccountsService/icons/$U"
  if [ -f "/var/lib/AccountsService/users/$U" ]; then
    if grep -q '^Icon=' "/var/lib/AccountsService/users/$U"; then
      sed -i "s|^Icon=.*|Icon=/var/lib/AccountsService/icons/$U|" \
        "/var/lib/AccountsService/users/$U"
    else
      echo "Icon=/var/lib/AccountsService/icons/$U" \
        >> "/var/lib/AccountsService/users/$U"
    fi
  else
    printf '[User]\nIcon=/var/lib/AccountsService/icons/%s\n' "$U" \
      > "/var/lib/AccountsService/users/$U"
  fi
  echo "System avatar set for $U."
fi
echo "All done. The login screen and boot menu change on next boot."

# Distro logo for About This System / Info Center: point os-release at
# the MadOS mark and install it (plus the classic distributor-logo name)
# into the hicolor theme.
if [ -f "$HERE/cat.png" ]; then
  if grep -q '^LOGO=' /etc/os-release; then
    sed -i 's/^LOGO=.*/LOGO=mados/' /etc/os-release
  else
    echo 'LOGO=mados' >> /etc/os-release
  fi
  install -D -m644 "$HERE/cat.png" /usr/share/icons/hicolor/128x128/apps/mados.png
  install -D -m644 "$HERE/cat.png" /usr/share/icons/hicolor/128x128/apps/distributor-logo.png
  gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
  echo "logo: installed"
fi

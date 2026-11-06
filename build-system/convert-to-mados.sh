#!/bin/bash
# =============================================================================
# MadOS converter: turn a fresh Linux Mint 22.x install into MadOS.
#
#   curl -fsSL https://raw.githubusercontent.com/MadelynKateJ/MadOS/main/build-system/convert-to-mados.sh | sudo bash
#
# Or from a clone of this repo:  sudo bash build-system/convert-to-mados.sh
#
# What it does, in order (the same steps proven on the first MadOS install):
#   1. KDE Plasma 6.8 via KDE neon          (kde68/kde68-cubic.sh)
#   2. The six MadOS component packages     (from the v0.1.0-alpha release)
#   3. SDDM as the display manager, Plasma as the session, Cinnamon out
#   4. The de-Mint sweep                    (branding/demint.sh)
#   5. Plymouth boot splash                 (branding/plymouth/)
#   6. Hostname: MadOS
#   7. Neofetch cat for your user           (branding/neofetch/)
#   8. MadOS Sakura, the default look       (branding/sakura/)
#      ...including the system pieces (branding/sakura/sakura-system.sh):
#      SDDM login theme, GRUB boot theme, system avatar + distro logo,
#      manual login (no user list, no autologin), no virtual keyboard.
#
# Expect a long run (the neon upgrade is hundreds of packages) and one
# reboot at the end. Log: /var/log/mados-convert.log
# =============================================================================
exec > >(tee -a /var/log/mados-convert.log) 2>&1
set -e
export DEBIAN_FRONTEND=noninteractive

say() { echo; echo "=== MadOS converter: $* ==="; }

# --- Preflight ---------------------------------------------------------------
if [ "$(id -u)" != "0" ]; then
  echo "Run this as root (sudo). Aborting."
  exit 1
fi
. /etc/os-release
if [ "$ID" != "linuxmint" ]; then
  echo "This converter targets a Linux Mint install (found ID=$ID). Aborting."
  exit 1
fi
case "$VERSION_ID" in
  22.*) ;;
  *) echo "Warning: tested on Mint 22.x, this is $VERSION_ID. Continuing anyway." ;;
esac
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo root)}"
echo "Converting this Mint $VERSION_ID system to MadOS 0.1.0-alpha."
echo "User getting the per-user setup: $TARGET_USER"

# --- Find (or fetch) the build-system files ----------------------------------
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
if [ -n "$HERE" ] && [ -f "$HERE/kde68/kde68-cubic.sh" ]; then
  BS="$HERE"
else
  say "fetching the MadOS repo"
  TMP="$(mktemp -d)"
  curl -fsSL https://github.com/MadelynKateJ/MadOS/archive/refs/heads/main.tar.gz \
    | tar -xz -C "$TMP"
  BS="$TMP/MadOS-main/build-system"
fi
echo "Build files: $BS"

# --- Stage 1: KDE Plasma 6.8 (KDE neon) ---------------------------------------
say "stage 1/8: KDE Plasma 6.8"
bash "$BS/kde68/kde68-cubic.sh"

# --- Stage 2: MadOS component packages ----------------------------------------
say "stage 2/8: MadOS components"
DEBS=/tmp/mados-debs
mkdir -p "$DEBS"
REL=https://github.com/MadelynKateJ/MadOS/releases/download/v0.1.5-alpha
ok=1
for f in mados-core.deb mados-desktop.deb mados-settings.deb \
         mados-ui.deb mados-update.deb mados-welcome.deb; do
  curl -fsSL "$REL/$f" -o "$DEBS/$f" || ok=0
done
if [ "$ok" = "1" ]; then
  dpkg -i "$DEBS"/*.deb || apt-get install -f -y
else
  echo "WARNING: could not download the MadOS packages; skipping stage 2."
  echo "Install them later from the GitHub release (v0.1.5-alpha)."
fi

# --- Stage 2b: enrol in the MadOS update channel -------------------------------
# From here on, MadOS package updates arrive through MadOS Update
# (apt) like any other system update.
say "stage 2b: MadOS update channel"
echo "deb [trusted=yes] https://madelynkatej.github.io/MadOS/ ./" \
  > /etc/apt/sources.list.d/mados.list
apt-get update -o Dir::Etc::sourcelist="sources.list.d/mados.list" \
  -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" || true

# --- Stage 3: SDDM + Plasma session, Cinnamon out ------------------------------
say "stage 3/8: display manager and session"
echo "sddm shared/default-x-display-manager select sddm" | debconf-set-selections
echo "/usr/bin/sddm" > /etc/X11/default-display-manager
systemctl disable lightdm 2>/dev/null || true
systemctl enable sddm 2>/dev/null || true
apt-get purge -y cinnamon cinnamon-common cinnamon-session \
  cinnamon-control-center cinnamon-settings-daemon nemo nemo-data \
  muffin cjs || true
apt-get autoremove --purge -y

# --- Stage 4: the de-Mint sweep -------------------------------------------------
say "stage 4/8: de-Mint sweep"
bash "$BS/branding/demint.sh"

# --- Stage 5: Plymouth splash ----------------------------------------------------
say "stage 5/8: Plymouth splash"
mkdir -p /usr/share/plymouth/themes/mados
cp "$BS"/branding/plymouth/mados.plymouth "$BS"/branding/plymouth/mados.script \
   "$BS"/branding/plymouth/splash.png /usr/share/plymouth/themes/mados/
chmod -R a+rX /usr/share/plymouth/themes/mados
update-alternatives --install /usr/share/plymouth/themes/default.plymouth \
  default.plymouth /usr/share/plymouth/themes/mados/mados.plymouth 100
update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/mados/mados.plymouth
systemctl disable casper-md5check.service 2>/dev/null || true
update-initramfs -u

# --- Stage 6: hostname ------------------------------------------------------------
say "stage 6/8: hostname"
hostnamectl set-hostname MadOS || true
sed -i 's/127\.0\.1\.1.*/127.0.1.1\tMadOS/' /etc/hosts || true

# --- Stage 7: neofetch cat for the user --------------------------------------------
say "stage 7/8: neofetch"
apt-get install -y neofetch || true
if [ "$TARGET_USER" != "root" ] && id "$TARGET_USER" >/dev/null 2>&1; then
  UHOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
  mkdir -p "$UHOME/.config/neofetch"
  cp "$BS/branding/neofetch/cat.txt" "$UHOME/.config/neofetch/cat.txt"
  CONF="$UHOME/.config/neofetch/config.conf"
  [ -f "$CONF" ] || neofetch --print_config > "$CONF" 2>/dev/null || touch "$CONF"
  grep -q '^image_backend' "$CONF" \
    && sed -i 's/^image_backend=.*/image_backend="ascii"/' "$CONF" \
    || echo 'image_backend="ascii"' >> "$CONF"
  grep -q '^image_source' "$CONF" \
    && sed -i "s|^image_source=.*|image_source=\"$UHOME/.config/neofetch/cat.txt\"|" "$CONF" \
    || echo "image_source=\"$UHOME/.config/neofetch/cat.txt\"" >> "$CONF"
  grep -q '^ascii_colors' "$CONF" \
    && sed -i 's/^ascii_colors=.*/ascii_colors=(5)/' "$CONF" \
    || echo 'ascii_colors=(5)' >> "$CONF"
  chown -R "$TARGET_USER":"$TARGET_USER" "$UHOME/.config/neofetch"
fi

# --- Stage 8: MadOS Sakura, the default look --------------------------------------
say "stage 8/8: MadOS Sakura"
if [ "$TARGET_USER" != "root" ] && id "$TARGET_USER" >/dev/null 2>&1; then
  UHOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
  UUID_NUM="$(id -u "$TARGET_USER")"
  SK="$BS/branding/sakura"
  mkdir -p "$UHOME/.local/share/color-schemes" \
           "$UHOME/.local/share/aurorae/themes" \
           "$UHOME/.local/share/icons" \
           "$UHOME/Pictures"
  cp "$SK/MadOSSakura.colors" "$UHOME/.local/share/color-schemes/"
  cp "$SK/mados-sakura-wallpaper.jpg" "$UHOME/Pictures/"
  rm -rf "$UHOME/.local/share/aurorae/themes/MadOSSakura"
  cp -r "$SK/decoration/MadOSSakura" "$UHOME/.local/share/aurorae/themes/"
  if [ ! -d "$UHOME/.local/share/icons/candy-icons" ]; then
    if curl -fsSL -o /tmp/candy-icons.tar.gz \
        https://codeload.github.com/EliverLara/candy-icons/tar.gz/refs/heads/master; then
      mkdir -p "$UHOME/.local/share/icons/candy-icons"
      tar -xzf /tmp/candy-icons.tar.gz -C "$UHOME/.local/share/icons/candy-icons" \
        --strip-components=1 || echo "WARNING: Candy icons extract failed; continuing."
    else
      echo "WARNING: Candy icons download failed; continuing without them."
    fi
  fi
  # Round 2 pieces: face (launcher + avatar), Konsole scheme, bells,
  # splash, cursors, UI font.
  mkdir -p "$UHOME/.local/share/mados" "$UHOME/.local/share/konsole" \
           "$UHOME/.local/share/sounds" "$UHOME/.local/share/plasma" \
           "$UHOME/.local/share/fonts"
  cp "$SK/cat.png" "$UHOME/.local/share/mados/cat.png"
  cp "$SK/cat.png" "$UHOME/.face.icon"
  cp "$SK/cat.png" "$UHOME/.face"
  cp "$SK/konsole/MadOSSakura.colorscheme" "$UHOME/.local/share/konsole/"
  PROF="$(ls "$UHOME"/.local/share/konsole/*.profile 2>/dev/null | head -1)"
  if [ -z "$PROF" ]; then
    printf '[Appearance]\nColorScheme=MadOSSakura\nFont=Hack,11,-1,5,50,0,0,0,0,0\n\n[General]\nName=MadOS Sakura\nParent=FALLBACK/\n\n[Scrolling]\nHistoryMode=2\n' \
      > "$UHOME/.local/share/konsole/MadOS Sakura.profile"
  fi
  rm -rf "$UHOME/.local/share/sounds/mados-bells"
  cp -r "$SK/sounds/mados-bells" "$UHOME/.local/share/sounds/"
  # Splash ships as a look-and-feel package (Plasma 6.8 dropped the
  # old ksplash/Themes path entirely).
  rm -rf "$UHOME/.local/share/plasma/look-and-feel/org.mados.sakura"
  mkdir -p "$UHOME/.local/share/plasma/look-and-feel"
  cp -r "$SK/look-and-feel/org.mados.sakura" \
    "$UHOME/.local/share/plasma/look-and-feel/"
  if [ ! -d "$UHOME/.local/share/icons/catppuccin-latte-flamingo-cursors" ]; then
    if curl -fsSL -o /tmp/ctp-cursors.zip \
        https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-latte-flamingo-cursors.zip; then
      python3 -m zipfile -e /tmp/ctp-cursors.zip "$UHOME/.local/share/icons/" \
        || echo "WARNING: cursor extract failed; continuing."
    else
      echo "WARNING: cursor download failed; continuing without them."
    fi
  fi
  curl -fsSL -o "$UHOME/.local/share/fonts/Comfortaa.ttf" \
    "https://github.com/google/fonts/raw/main/ofl/comfortaa/Comfortaa%5Bwght%5D.ttf" \
    || echo "WARNING: Comfortaa download failed; keeping the default font."
  chown -R "$TARGET_USER":"$TARGET_USER" "$UHOME/.local/share" "$UHOME/Pictures" \
    "$UHOME/.face" "$UHOME/.face.icon"
  as_user() {
    runuser -u "$TARGET_USER" -- env HOME="$UHOME" \
      XDG_RUNTIME_DIR="/run/user/$UUID_NUM" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UUID_NUM/bus" "$@"
  }
  if [ -n "$PROF" ]; then
    as_user kwriteconfig6 --file "$PROF" --group Appearance \
      --key ColorScheme MadOSSakura || true
  else
    as_user kwriteconfig6 --file konsolerc --group "Desktop Entry" \
      --key DefaultProfile "MadOS Sakura.profile" || true
  fi
  as_user kwriteconfig6 --file kdeglobals --group Sounds \
    --key Theme mados-bells || true
  as_user kwriteconfig6 --file ksplashrc --group KSplash \
    --key Theme org.mados.sakura || true
  # MadOS power default: lock after 2 hours idle, not 5 minutes
  as_user kwriteconfig6 --file kscreenlockerrc --group Daemon \
    --key Autolock true || true
  as_user kwriteconfig6 --file kscreenlockerrc --group Daemon \
    --key Timeout 7200 || true
  as_user kwriteconfig6 --file kscreenlockerrc --group Daemon \
    --key LockOnResume false || true
  as_user kwriteconfig6 --file ksplashrc --group KSplash \
    --key Engine KSplashQML || true
  as_user kwriteconfig6 --file kscreenlockerrc --group Greeter \
    --group Wallpaper --group org.kde.image --group General \
    --key Image "file://$UHOME/Pictures/mados-sakura-wallpaper.jpg" || true
  if [ -d "$UHOME/.local/share/icons/catppuccin-latte-flamingo-cursors" ]; then
    as_user kwriteconfig6 --file kcminputrc --group Mouse \
      --key cursorTheme "Catppuccin Latte Flamingo" || true
  fi
  if [ -f "$UHOME/.local/share/fonts/Comfortaa.ttf" ]; then
    as_user kwriteconfig6 --file kdeglobals --group General --key font \
      "Comfortaa,10.5,-1,5,50,0,0,0,0,0" || true
  fi
  as_user kwriteconfig6 --file kdeglobals --group General \
    --key ColorScheme MadOSSakura || true
  as_user kwriteconfig6 --file kdeglobals --group General \
    --key AccentColor "244,114,182" || true
  if [ -f "$UHOME/.local/share/icons/candy-icons/index.theme" ]; then
    as_user kwriteconfig6 --file kdeglobals --group Icons \
      --key Theme candy-icons || true
  fi
  as_user kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 \
    --key library org.kde.kwin.aurorae || true
  as_user kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 \
    --key theme __aurorae__svg__MadOSSakura || true
  # Best-effort live apply if the session is already running; the config
  # keys above make Sakura stick at login either way.
  as_user plasma-apply-colorscheme MadOSSakura || true
  as_user plasma-apply-wallpaperimage \
    "$UHOME/Pictures/mados-sakura-wallpaper.jpg" || true
  as_user qdbus6 org.kde.KWin /KWin reconfigure || true
  # Launcher icon = the face; panel floats. Patch the shell's
  # appletsrc directly (Plasma 6.8's evaluateScript has no applets()
  # global). Applies at the next login / shell start.
  if [ -f "$UHOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
    python3 - "$UHOME" <<'PYEOF' || true
import re, sys
home = sys.argv[1]
p = home + '/.config/plasma-org.kde.plasma.desktop-appletsrc'
lines = open(p).read().split('\n')
sec = None
kick = None
for ln in lines:
    m = re.match(r'\[Containments\]\[(\d+)\]\[Applets\]\[(\d+)\]$', ln.strip())
    if m:
        sec = (m.group(1), m.group(2))
    if sec and ln.strip() in ('plugin=org.kde.plasma.kickoff',
                              'plugin=org.kde.plasma.kicker'):
        kick = sec
if kick:
    c, a = kick

    def set_key(section, key, val):
        global lines
        if section not in lines:
            lines.extend(['', section, key + '=' + val])
            return
        i = lines.index(section)
        j = i + 1
        while j < len(lines) and not lines[j].startswith('['):
            if lines[j].startswith(key + '='):
                lines[j] = key + '=' + val
                return
            j += 1
        lines.insert(i + 1, key + '=' + val)

    set_key('[Containments][%s][Applets][%s][Configuration][General]' % (c, a),
            'icon', home + '/.local/share/mados/cat.png')
    set_key('[Containments][%s]' % c, 'floating', '1')
    open(p, 'w').write('\n'.join(lines))
PYEOF
  fi
fi

# --- Stage 8b: stage the full Sakura tree + first-login apply ---------------
# Stage 8 above sets the config keys for rounds 1-2. The rest of the
# theme (desktop theme, Papirus folders, widgets, Firefox, Kate, ...)
# lives in branding/sakura/apply-sakura.sh and needs a live Plasma
# session, so it runs once at the user's first login instead. This is
# the same mechanism the MadOS ISO uses, so both routes converge.
say "stage 8b/8: Sakura first-login setup"
if [ "$TARGET_USER" != "root" ] && id "$TARGET_USER" >/dev/null 2>&1; then
  UHOME="${UHOME:-$(getent passwd "$TARGET_USER" | cut -d: -f6)}"
  mkdir -p "$UHOME/.local/share/mados" "$UHOME/.config/autostart"
  rm -rf "$UHOME/.local/share/mados/sakura"
  cp -r "$BS/branding/sakura" "$UHOME/.local/share/mados/sakura"
  cp "$BS/branding/sakura/first-login.sh" "$UHOME/.local/share/mados/first-login.sh"
  chmod +x "$UHOME/.local/share/mados/first-login.sh"
  # The Exec path must be ABSOLUTE: autostart entries get no shell
  # variable expansion, so a literal $HOME here never runs (found
  # the hard way on the first full converter test, 2026-11-04: the
  # entry sat there silently and the whole first-login half of
  # Sakura never fired). The ISO route always used an absolute
  # path, which is why only converted machines were affected.
  cat > "$UHOME/.config/autostart/mados-sakura.desktop" <<DEOF
[Desktop Entry]
Type=Application
Name=MadOS Sakura first-login setup
Exec=bash $UHOME/.local/share/mados/first-login.sh
X-KDE-autostart-phase=2
NoDisplay=true
DEOF
  chown -R "$TARGET_USER":"$TARGET_USER" "$UHOME/.local/share/mados" \
    "$UHOME/.config/autostart/mados-sakura.desktop"
fi

# --- Stage 8c: Sakura system pieces (SDDM theme, GRUB, avatar, logo) ---------
# Everything in sakura-system.sh needs root and has no live-session
# dependency, so it runs right here rather than at first login: the
# mados SDDM theme, the GRUB theme, the system avatar, the distro
# logo, the manual login (user hidden from the greeter, autologin
# stripped) and the virtual-keyboard off switch. Pass the target
# user through explicitly: the script keys its per-user pieces off
# SUDO_USER, and nested sudo/root shells do not always keep it set.
say "stage 8c/8: Sakura system pieces"
SUDO_USER="$TARGET_USER" bash "$BS/branding/sakura/sakura-system.sh"

say "DONE"
echo "This system is now MadOS 0.1.0-alpha. Reboot to see it:"
echo "  sudo reboot"
echo "Mint Welcome is still installed (kept on purpose until mados-welcome"
echo "is finished). Everything else Mint-branded is gone."
echo "The default look is MadOS Sakura: blossom wallpaper, blush colors,"
echo "flower window buttons (bud, half-open, full bloom), and the rest of"
echo "the theme finishes itself at your first login."
echo "The boot menu and login screen are already MadOS too. The login"
echo "is manual by design: no user list, type your username + password."

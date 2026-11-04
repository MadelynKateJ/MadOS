#!/bin/bash
# =============================================================================
# MadOS Sakura: apply the full default look to the current user's session.
#
#   bash build-system/branding/sakura/apply-sakura.sh
#
# Run as your normal user (NOT sudo) from a live Plasma session. Installs:
#   - the MadOS Sakura color scheme + pink accent color
#   - the sakura wallpaper (desktop AND lock screen)
#   - the Candy icon theme (downloaded from its GitHub repo, best effort)
#   - the MadOS Sakura window decoration (blossom buttons)
#   - the transparent light-rose Konsole scheme
#   - the MadOS cat face as launcher icon and user avatar
#   - Catppuccin Latte Flamingo cursors (downloaded, best effort)
#   - the MadOS Bells sound theme (soft synthesized bells)
#   - the Comfortaa UI font (user-local, best effort)
#   - the MadOS Sakura splash screen, set as default
#   - a floating panel
# Everything lands in ~/.local/share, ~/.local/share/fonts and ~/.config;
# pick other themes in System Settings to undo any of it.
# =============================================================================
set -e
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
if [ -f "$HERE/MadOSSakura.colors" ]; then
  SK="$HERE"
else
  TMP="$(mktemp -d)"
  curl -fsSL https://github.com/MadelynKateJ/MadOS/archive/refs/heads/main.tar.gz \
    | tar -xz -C "$TMP"
  SK="$TMP/MadOS-main/build-system/branding/sakura"
fi

mkdir -p "$HOME/.local/share/color-schemes" \
         "$HOME/.local/share/aurorae/themes" \
         "$HOME/.local/share/icons" \
         "$HOME/.local/share/konsole" \
         "$HOME/.local/share/sounds" \
         "$HOME/.local/share/plasma/look-and-feel" \
         "$HOME/.local/share/mados" \
         "$HOME/.local/share/fonts" \
         "$HOME/Pictures"

# Wallpaper, scheme, decoration
cp "$SK/MadOSSakura.colors" "$HOME/.local/share/color-schemes/"
cp "$SK/mados-sakura-wallpaper.jpg" "$HOME/Pictures/"
rm -rf "$HOME/.local/share/aurorae/themes/MadOSSakura"
cp -r "$SK/decoration/MadOSSakura" "$HOME/.local/share/aurorae/themes/"

# Face: launcher icon + avatar
cp "$SK/cat.png" "$HOME/.local/share/mados/cat.png"
cp "$SK/cat.png" "$HOME/.face.icon"
cp "$SK/cat.png" "$HOME/.face"

# Konsole scheme (onto the current profile, or a new default profile)
cp "$SK/konsole/MadOSSakura.colorscheme" "$HOME/.local/share/konsole/"
PROF="$(ls "$HOME"/.local/share/konsole/*.profile 2>/dev/null | head -1)"
if [ -n "$PROF" ]; then
  kwriteconfig6 --file "$PROF" --group Appearance --key ColorScheme MadOSSakura
else
  printf '[Appearance]\nColorScheme=MadOSSakura\nFont=Hack,11,-1,5,50,0,0,0,0,0\n\n[General]\nName=MadOS Sakura\nParent=FALLBACK/\n\n[Scrolling]\nHistoryMode=2\n' \
    > "$HOME/.local/share/konsole/MadOS Sakura.profile"
  kwriteconfig6 --file konsolerc --group "Desktop Entry" \
    --key DefaultProfile "MadOS Sakura.profile"
fi

# Candy icons (best effort)
if [ ! -d "$HOME/.local/share/icons/candy-icons" ]; then
  if curl -fsSL -o /tmp/candy-icons.tar.gz \
      https://codeload.github.com/EliverLara/candy-icons/tar.gz/refs/heads/master; then
    mkdir -p "$HOME/.local/share/icons/candy-icons"
    tar -xzf /tmp/candy-icons.tar.gz -C "$HOME/.local/share/icons/candy-icons" \
      --strip-components=1 || echo "WARNING: Candy icons extract failed; continuing."
  else
    echo "WARNING: Candy icons download failed; continuing without them."
  fi
fi

# Cursors: Catppuccin Latte Flamingo (best effort)
if [ ! -d "$HOME/.local/share/icons/catppuccin-latte-flamingo-cursors" ]; then
  if curl -fsSL -o /tmp/ctp-cursors.zip \
      https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-latte-flamingo-cursors.zip; then
    python3 -m zipfile -e /tmp/ctp-cursors.zip "$HOME/.local/share/icons/" \
      || echo "WARNING: cursor extract failed; continuing."
  else
    echo "WARNING: cursor download failed; continuing without them."
  fi
fi
if [ -d "$HOME/.local/share/icons/catppuccin-latte-flamingo-cursors" ]; then
  plasma-apply-cursortheme "Catppuccin Latte Flamingo" || true
fi

# Sound theme
rm -rf "$HOME/.local/share/sounds/mados-bells"
cp -r "$SK/sounds/mados-bells" "$HOME/.local/share/sounds/"
kwriteconfig6 --file kdeglobals --group Sounds --key Theme mados-bells

# UI font (best effort)
if curl -fsSL -o "$HOME/.local/share/fonts/Comfortaa.ttf" \
    "https://github.com/google/fonts/raw/main/ofl/comfortaa/Comfortaa%5Bwght%5D.ttf"; then
  fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
  kwriteconfig6 --file kdeglobals --group General --key font \
    "Comfortaa,10.5,-1,5,50,0,0,0,0,0"
else
  echo "WARNING: Comfortaa download failed; keeping the current font."
fi

# Splash screen, as default. Plasma 6.8 dropped the old
# ~/.local/share/ksplash/Themes path (verified: /usr/share/ksplash
# does not exist on the neon build); splashes ship inside
# look-and-feel packages now.
rm -rf "$HOME/.local/share/plasma/look-and-feel/org.mados.sakura"
mkdir -p "$HOME/.local/share/plasma/look-and-feel"
cp -r "$SK/look-and-feel/org.mados.sakura" "$HOME/.local/share/plasma/look-and-feel/"
kwriteconfig6 --file ksplashrc --group KSplash --key Theme org.mados.sakura
kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML

# MadOS power default: lock after 2 hours idle, not 5 minutes
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock true
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 7200
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume false

# Live applies
plasma-apply-colorscheme MadOSSakura || true
plasma-apply-wallpaperimage "$HOME/Pictures/mados-sakura-wallpaper.jpg" || true
kwriteconfig6 --file kdeglobals --group General --key AccentColor "244,114,182"
if [ -f "$HOME/.local/share/icons/candy-icons/index.theme" ]; then
  kwriteconfig6 --file kdeglobals --group Icons --key Theme candy-icons
fi
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 \
  --key library org.kde.kwin.aurorae
kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 \
  --key theme __aurorae__svg__MadOSSakura
kwriteconfig6 --file kscreenlockerrc --group Greeter --group Wallpaper \
  --group org.kde.image --group General \
  --key Image "file://$HOME/Pictures/mados-sakura-wallpaper.jpg"
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null \
  || qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true

# Launcher icon = the face; panel floats. Done by patching the
# shell's appletsrc directly: Plasma 6.8's evaluateScript context has
# no applets() global (verified on the TV machine), so the JS route
# errors out. Patch, then restart the shell to load it.
python3 - "$HOME" <<'PYEOF' || true
import re, sys
home = sys.argv[1]
p = home + '/.config/plasma-org.kde.plasma.desktop-appletsrc'
try:
    lines = open(p).read().split('\n')
except FileNotFoundError:
    raise SystemExit(0)
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
kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
if qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript \
    'print("shell-ok")' >/dev/null 2>&1; then
  kquitapp6 plasmashell 2>/dev/null || true
  sleep 2
  (setsid plasmashell >/dev/null 2>&1 &)
fi

echo "MadOS Sakura applied in full: scheme, wallpaper (desktop + lock),"
echo "icons, blossom buttons, Konsole, face, cursors, bells, font, splash."
echo "Restart the session (or plasmashell) for the font to show everywhere."

# 12. Desktop theme: blush Breeze into MadOS Sakura (pink menus/dialogs,
#     blossoms tucked into the dialog background). Rebuilt from the
#     system Breeze copy each run; safe to re-run.
if [ -f "$HERE/patch-desktoptheme.py" ]; then
  python3 "$HERE/patch-desktoptheme.py" || true
  plasma-apply-desktoptheme MadOSSakura 2>/dev/null || \
    kwriteconfig6 --file plasmarc --group Theme --key name MadOSSakura
fi

# 13. Pink folders: Papirus icon theme with the pink folder set.
#     (Reversible: plasma-apply-icontheme candy-icons.)
if [ ! -d "$HOME/.local/share/icons/Papirus" ]; then
  cd /tmp
  curl -fsSL -o papirus.tar.gz https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/tags/20260801.tar.gz
  rm -rf /tmp/papirus-src && mkdir -p /tmp/papirus-src
  tar -xzf papirus.tar.gz -C /tmp/papirus-src --strip-components=1
  mkdir -p "$HOME/.local/share/icons"
  cp -r /tmp/papirus-src/Papirus /tmp/papirus-src/Papirus-Dark /tmp/papirus-src/Papirus-Light "$HOME/.local/share/icons/"
fi
if [ -d "$HOME/.local/share/icons/Papirus" ]; then
  curl -fsSL -o /tmp/papirus-folders https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders
  chmod +x /tmp/papirus-folders
  /tmp/papirus-folders -C pink --theme Papirus </dev/null || true
  plasma-apply-icontheme Papirus || \
    kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus
fi

# 13b. Soften the folder pink (stock Papirus pink is a bit hot):
#      #f06292 -> #F194BC, #ec407a -> #E87EA8 across the pink folders.
for T in Papirus Papirus-Light Papirus-Dark; do
  D="$HOME/.local/share/icons/$T"
  [ -d "$D" ] || continue
  find "$D" -path '*places*' -name 'folder-pink*.svg' -print0 | while IFS= read -r -d '' f; do
    sed -i 's/#f06292/#F194BC/g; s/#F06292/#F194BC/g; s/#ec407a/#E87EA8/g; s/#EC407A/#E87EA8/g' "$f"
  done
done

# 14. Pink shell prompt.
if ! grep -q 'MadOS Sakura prompt' "$HOME/.bashrc"; then
cat >> "$HOME/.bashrc" <<'PROMPT'

# MadOS Sakura prompt: soft pink blossom
PS1='\[\e[38;5;218m\]❀ \[\e[38;5;211m\]\u@\h\[\e[0m\] \[\e[38;5;225m\]\w\[\e[0m\] \[\e[38;5;218m\]❯\[\e[0m\] '
PROMPT
fi

# 15. Day/dusk wallpaper pair, auto-switching at 07:00 and 17:00.
mkdir -p "$HOME/Pictures"
cp "$HERE/mados-sakura-dusk.jpg" "$HOME/Pictures/" 2>/dev/null || true
UIDN=$(id -u)
ENVV="DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$UIDN/bus"
( crontab -l 2>/dev/null | grep -v 'mados-sakura' ; \
  echo "0 7 * * * $ENVV plasma-apply-wallpaperimage $HOME/Pictures/mados-sakura-wallpaper.jpg # mados-sakura-day" ; \
  echo "0 17 * * * $ENVV plasma-apply-wallpaperimage $HOME/Pictures/mados-sakura-dusk.jpg # mados-sakura-dusk" ) | crontab -

# 16. A clock on the desktop.
python3 "$HERE/add-clock.py" || true

# 17. Pink Firefox, wherever its profile lives (regular, XDG or Flatpak).
for BASE in "$HOME/.config/mozilla/firefox" "$HOME/.mozilla/firefox" \
            "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox" \
            "$HOME/.var/app/org.mozilla.firefox/.config/mozilla/firefox"; do
  for PROF in "$BASE"/*.default*; do
    [ -d "$PROF" ] || continue
    mkdir -p "$PROF/chrome"
    cp "$HERE/firefox/userChrome.css" "$PROF/chrome/userChrome.css"
    cp "$HERE/firefox/userContent.css" "$PROF/chrome/userContent.css"
    grep -q 'legacyUserProfileCustomizations' "$PROF/user.js" 2>/dev/null || \
      echo 'user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);' >> "$PROF/user.js"
  done
done

# 18. Jelly windows, magic-lamp minimize, dreamier blur.
kwriteconfig6 --file kwinrc --group Plugins --key wobblywindowsEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled true
kwriteconfig6 --file kwinrc --group Effect-Blur --key BlurStrength 13
qdbus6 org.kde.KWin /KWin reconfigure || true

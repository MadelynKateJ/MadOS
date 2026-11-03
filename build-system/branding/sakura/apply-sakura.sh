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
         "$HOME/.local/share/ksplash/Themes" \
         "$HOME/.local/share/mados" \
         "$HOME/.local/share/fonts" \
         "$HOME/Pictures"

# Wallpaper, scheme, decoration
cp "$SK/MadOSSakura.colors" "$HOME/.local/share/color-schemes/"
cp "$SK/mados-sakura-wallpaper.jpg" "$HOME/Pictures/"
rm -rf "$HOME/.local/share/aurorae/themes/MadOSSakura"
cp -r "$SK/decoration/MadOSSakura" "$HOME/.local/share/aurorae/themes/"

# Face: launcher icon + avatar
cp "$SK/face.png" "$HOME/.local/share/mados/face.png"
cp "$SK/face.png" "$HOME/.face.icon"
cp "$SK/face.png" "$HOME/.face"

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

# Splash screen, as default
rm -rf "$HOME/.local/share/ksplash/Themes/MadOSSakura"
cp -r "$SK/ksplash/MadOSSakura" "$HOME/.local/share/ksplash/Themes/"
kwriteconfig6 --file ksplashrc --group KSplash --key Theme MadOSSakura
kwriteconfig6 --file ksplashrc --group KSplash --key Engine KSplashQML

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

# Launcher icon = the face; panel floats
JS='applets().filter(function(a){return a.pluginName.indexOf("kickoff")>=0||a.pluginName.indexOf("kicker")>=0}).forEach(function(a){a.currentConfigGroup=["General"];a.writeConfig("icon","'"$HOME"'/.local/share/mados/face.png")});panels().forEach(function(p){p.floating=true});'
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$JS" \
  2>/dev/null || true
kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

echo "MadOS Sakura applied in full: scheme, wallpaper (desktop + lock),"
echo "icons, blossom buttons, Konsole, face, cursors, bells, font, splash."
echo "Restart the session (or plasmashell) for the font to show everywhere."

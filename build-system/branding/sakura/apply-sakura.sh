#!/bin/bash
# =============================================================================
# MadOS Sakura: apply the default look to the current user's Plasma session.
#
#   bash build-system/branding/sakura/apply-sakura.sh
#
# Run as your normal user (NOT sudo) from a live Plasma session. Installs:
#   - the MadOS Sakura color scheme + pink accent color
#   - the sakura wallpaper
#   - the Candy icon theme (downloaded from its GitHub repo, best effort)
#   - the MadOS Sakura window decoration (blossom buttons)
# Everything lands in ~/.local/share and ~/.config; delete those files and
# pick another theme in System Settings to undo it.
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
         "$HOME/Pictures"

cp "$SK/MadOSSakura.colors" "$HOME/.local/share/color-schemes/"
cp "$SK/mados-sakura-wallpaper.jpg" "$HOME/Pictures/"
rm -rf "$HOME/.local/share/aurorae/themes/MadOSSakura"
cp -r "$SK/decoration/MadOSSakura" "$HOME/.local/share/aurorae/themes/"

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
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null \
  || qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

echo "MadOS Sakura applied: scheme, wallpaper, icons, blossom window buttons."

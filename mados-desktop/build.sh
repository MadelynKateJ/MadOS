#!/bin/bash
#
# mados-desktop build: refresh the theming payload staged in
# packaging/ from its canonical home in build-system/branding
# (the same staging build-system/publish-repo.sh performs when
# publishing the channel), normalize modes, and build the .deb
# at the repository root, where publish-repo.sh expects it.
#
# Unlike the app packages' build scripts this one does not
# install: it is just as likely to run on a machine that is not
# MadOS at all. Install the result with dpkg/apt yourself.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(dirname "$PROJECT_DIR")"

echo "========================================"
echo "      MadOS Desktop Build System"
echo "========================================"

echo "[1/3] Staging theming payload from build-system/branding..."
rm -rf "$PROJECT_DIR/packaging/usr/share/mados/sakura" \
       "$PROJECT_DIR/packaging/usr/share/mados/neofetch"
mkdir -p "$PROJECT_DIR/packaging/usr/share/mados"
cp -r "$ROOT/build-system/branding/sakura" \
      "$PROJECT_DIR/packaging/usr/share/mados/sakura"
mkdir -p "$PROJECT_DIR/packaging/usr/share/mados/neofetch"
cp "$ROOT/build-system/branding/neofetch/cat.txt" \
   "$PROJECT_DIR/packaging/usr/share/mados/neofetch/cat.txt"

echo "[2/3] Normalizing modes..."
find "$PROJECT_DIR/packaging" -type d -exec chmod 755 {} +
find "$PROJECT_DIR/packaging" -type f -exec chmod 644 {} +
chmod 755 "$PROJECT_DIR/packaging/DEBIAN/postinst" \
          "$PROJECT_DIR/packaging/DEBIAN/prerm" \
          "$PROJECT_DIR/packaging/usr/share/mados/first-login.sh"

echo "[3/3] Building package..."
dpkg-deb --build "$PROJECT_DIR/packaging" "$ROOT/mados-desktop.deb"

echo ""
echo "========================================"
echo "✓ mados-desktop.deb built at repo root"
echo "========================================"

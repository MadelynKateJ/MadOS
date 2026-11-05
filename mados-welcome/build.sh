#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

PACKAGE_DIR="$PROJECT_DIR/packaging/usr/share/mados-welcome"

echo "========================================"
echo "        MadOS Build System"
echo "========================================"
echo

echo "[1/7] Cleaning old package..."
rm -f "$PROJECT_DIR/mados-welcome.deb"

echo "[2/7] Cleaning package source..."
rm -rf "$PACKAGE_DIR"

mkdir -p "$PACKAGE_DIR"

echo "[3/7] Copying source tree..."
cp -r "$PROJECT_DIR/src/"* "$PACKAGE_DIR/"

find "$PACKAGE_DIR" -name "*.py" -exec chmod 755 {} \;

chmod 755 "$PROJECT_DIR/packaging/usr/bin/madoswelcome"

echo "[4/7] Building package..."
# Normalize modes: a package must install world-readable files
# no matter what umask the build shell runs with.
find "$PROJECT_DIR/packaging" -type d -exec chmod 755 {} +
find "$PROJECT_DIR/packaging" -type f -exec chmod 644 {} +
find "$PROJECT_DIR/packaging/usr/bin" -type f -exec chmod 755 {} + 2>/dev/null || true
dpkg-deb --build \
    "$PROJECT_DIR/packaging" \
    "$PROJECT_DIR/mados-welcome.deb"

echo "[5/7] Installing package..."
sudo apt install --reinstall \
    "$PROJECT_DIR/mados-welcome.deb" \
    -y

echo "[6/7] Updating desktop database..."
sudo update-desktop-database /usr/share/applications 2>/dev/null || true

echo "[7/7] Launching..."
madoswelcome &

echo
echo "========================================"
echo "✓ Build Complete!"
echo "========================================"

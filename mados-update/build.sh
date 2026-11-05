#!/bin/bash

set -e

echo "========================================"
echo "      MadOS Update Build System"
echo "========================================"
echo

PACKAGE="packaging"

echo "[1/6] Cleaning old package..."
rm -rf "$PACKAGE/usr/share/mados-update"
mkdir -p "$PACKAGE/usr/share/mados-update/widgets"

echo "[2/6] Copying source..."
cp src/madosupdate.py "$PACKAGE/usr/share/mados-update/"
cp src/widgets/*.py "$PACKAGE/usr/share/mados-update/widgets/"

if [ -d src/helper ]; then
    mkdir -p "$PACKAGE/usr/share/mados-update/helper"
    cp src/helper/*.py "$PACKAGE/usr/share/mados-update/helper/"
fi

echo "[3/6] Building package..."
# Normalize modes: a package must install world-readable files
# no matter what umask the build shell runs with.
find "$PACKAGE" -type d -exec chmod 755 {} +
find "$PACKAGE" -type f -exec chmod 644 {} +
find "$PACKAGE/usr/bin" -type f -exec chmod 755 {} + 2>/dev/null || true
dpkg-deb --build "$PACKAGE" mados-update.deb

echo "[4/6] Installing..."
sudo apt install -y ./mados-update.deb

echo "[5/6] Launching..."
mados-update &

echo
echo "========================================"
echo "✓ Build Complete!"
echo "========================================"

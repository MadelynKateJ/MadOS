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
dpkg-deb --build "$PACKAGE" mados-update.deb

echo "[4/6] Installing..."
sudo apt install -y ./mados-update.deb

echo "[5/6] Launching..."
mados-update &

echo
echo "========================================"
echo "✓ Build Complete!"
echo "========================================"

#!/bin/bash

set -e

echo "========================================"
echo "        MadOS UI Build System"
echo "========================================"
echo

PACKAGE=packaging
TARGET=$PACKAGE/usr/lib/python3/dist-packages/mados_ui

echo "[1/5] Cleaning old package..."
rm -rf "$TARGET"
mkdir -p "$TARGET"

echo "[2/5] Copying source..."

cp -r src/* "$TARGET/"
cp *.css "$TARGET/" 2>/dev/null || true

find "$TARGET" -name "*.pyc" -delete
find "$TARGET" -name "__pycache__" -type d -exec rm -rf {} +

echo "[3/5] Building package..."
dpkg-deb --build "$PACKAGE" mados-ui.deb

echo "[4/5] Installing..."
sudo dpkg -i mados-ui.deb

echo
echo "========================================"
echo "✓ MadOS UI Installed!"
echo "========================================"

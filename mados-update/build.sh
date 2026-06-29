#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "      MadOS Update Build System"
echo "========================================"
echo ""

echo "[1/6] Cleaning old package..."
rm -f "$PROJECT_DIR/mados-update.deb"

echo "[2/6] Preparing package..."
rm -rf "$PROJECT_DIR/packaging/usr/share/mados-update"
mkdir -p "$PROJECT_DIR/packaging/usr/share/mados-update"

echo "[3/6] Copying source..."
cp -r "$PROJECT_DIR/src/"* \
      "$PROJECT_DIR/packaging/usr/share/mados-update/"

chmod 755 "$PROJECT_DIR/packaging/usr/bin/mados-update"

echo "[4/6] Building package..."
dpkg-deb --build \
    "$PROJECT_DIR/packaging" \
    "$PROJECT_DIR/mados-update.deb"

echo "[5/6] Installing..."
sudo apt install --reinstall \
    "$PROJECT_DIR/mados-update.deb" \
    -y

echo "[6/6] Launching..."
mados-update &

echo ""
echo "========================================"
echo "✓ Build Complete!"
echo "========================================"

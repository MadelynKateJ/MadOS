#!/bin/bash

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================"
echo "       MadOS Core Build System"
echo "========================================"
echo ""

echo "[1/5] Cleaning old package..."
rm -f "$PROJECT_DIR/mados-core.deb"

echo "[2/5] Preparing package..."
rm -rf "$PROJECT_DIR/packaging/usr/lib/python3/dist-packages/mados_core"
mkdir -p "$PROJECT_DIR/packaging/usr/lib/python3/dist-packages/mados_core"

echo "[3/5] Copying source..."
cp *.py \
"$PROJECT_DIR/packaging/usr/lib/python3/dist-packages/mados_core/"

echo "[4/5] Building package..."
# Normalize modes: a package must install world-readable files
# no matter what umask the build shell runs with.
find "$PROJECT_DIR/packaging" -type d -exec chmod 755 {} +
find "$PROJECT_DIR/packaging" -type f -exec chmod 644 {} +
find "$PROJECT_DIR/packaging/usr/bin" -type f -exec chmod 755 {} + 2>/dev/null || true
dpkg-deb --build \
"$PROJECT_DIR/packaging" \
"$PROJECT_DIR/mados-core.deb"

echo "[5/5] Installing..."
sudo apt install --reinstall \
"$PROJECT_DIR/mados-core.deb" \
-y

echo ""
echo "========================================"
echo "✓ MadOS Core Installed!"
echo "========================================"

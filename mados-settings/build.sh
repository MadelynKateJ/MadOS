#!/bin/bash

set -e

echo "========================================"
echo "      MadOS Settings Build System"
echo "========================================"

PACKAGE=packaging

rm -rf "$PACKAGE/usr/share/mados-settings"

mkdir -p "$PACKAGE/usr/share/mados-settings"

cp -r src/* "$PACKAGE/usr/share/mados-settings/"

# Normalize modes: a package must install world-readable files
# no matter what umask the build shell runs with.
find "$PACKAGE" -type d -exec chmod 755 {} +
find "$PACKAGE" -type f -exec chmod 644 {} +
find "$PACKAGE/usr/bin" -type f -exec chmod 755 {} + 2>/dev/null || true
dpkg-deb --build "$PACKAGE" mados-settings.deb

sudo dpkg -i mados-settings.deb

mados-settings &

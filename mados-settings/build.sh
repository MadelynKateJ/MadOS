#!/bin/bash

set -e

echo "========================================"
echo "      MadOS Settings Build System"
echo "========================================"

PACKAGE=packaging

rm -rf "$PACKAGE/usr/share/mados-settings"

mkdir -p "$PACKAGE/usr/share/mados-settings"

cp -r src/* "$PACKAGE/usr/share/mados-settings/"

dpkg-deb --build "$PACKAGE" mados-settings.deb

sudo dpkg -i mados-settings.deb

mados-settings &

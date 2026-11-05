#!/bin/bash
#
# publish-repo.sh — build the six MadOS packages and publish them
# as a flat APT repository on the gh-pages branch, which GitHub
# Pages serves at https://madelynkatej.github.io/MadOS/
#
# Machines enrol once with:
#   deb [trusted=yes] https://madelynkatej.github.io/MadOS/ ./
# in /etc/apt/sources.list.d/mados.list, and from then on MadOS
# Update (and apt generally) pulls MadOS package updates like
# any other system update.
#
# Usage:
#   ./publish-repo.sh           build packages + repo locally
#   ./publish-repo.sh --push    also commit + push the gh-pages branch
#
# Version discipline: apt only offers a package as an update when
# the repo version is NEWER than the installed one. Bump the
# Version in each package's packaging/DEBIAN/control before
# publishing a change (patch bumps for everything is fine).

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/apt-repo"

norm() {
    find "$1" -type d -exec chmod 755 {} +
    find "$1" -type f -exec chmod 644 {} +
    find "$1/usr/bin" -type f -exec chmod 755 {} + 2>/dev/null || true
}

echo "== Building packages =="

# mados-core
( cd "$ROOT/mados_core"
  rm -rf packaging/usr/lib/python3/dist-packages/mados_core
  mkdir -p packaging/usr/lib/python3/dist-packages/mados_core
  cp *.py packaging/usr/lib/python3/dist-packages/mados_core/
  norm packaging
  dpkg-deb --build packaging mados-core.deb > /dev/null )

# mados-ui
( cd "$ROOT/mados-ui"
  rm -rf packaging/usr/lib/python3/dist-packages/mados_ui
  mkdir -p packaging/usr/lib/python3/dist-packages/mados_ui
  cp -r src/* packaging/usr/lib/python3/dist-packages/mados_ui/
  cp *.css packaging/usr/lib/python3/dist-packages/mados_ui/ 2>/dev/null || true
  find packaging/usr/lib/python3/dist-packages/mados_ui -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
  norm packaging
  dpkg-deb --build packaging mados-ui.deb > /dev/null )

# mados-settings
( cd "$ROOT/mados-settings"
  rm -rf packaging/usr/share/mados-settings
  mkdir -p packaging/usr/share/mados-settings
  cp -r src/* packaging/usr/share/mados-settings/
  norm packaging
  dpkg-deb --build packaging mados-settings.deb > /dev/null )

# mados-update
( cd "$ROOT/mados-update"
  rm -rf packaging/usr/share/mados-update
  mkdir -p packaging/usr/share/mados-update/widgets packaging/usr/share/mados-update/helper
  cp src/madosupdate.py packaging/usr/share/mados-update/
  cp src/widgets/*.py packaging/usr/share/mados-update/widgets/
  cp src/helper/*.py packaging/usr/share/mados-update/helper/
  norm packaging
  dpkg-deb --build packaging mados-update.deb > /dev/null )

# mados-welcome
( cd "$ROOT/mados-welcome"
  rm -rf packaging/usr/share/mados-welcome
  mkdir -p packaging/usr/share/mados-welcome
  cp -r src/* packaging/usr/share/mados-welcome/
  find packaging/usr/share/mados-welcome -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
  norm packaging
  dpkg-deb --build packaging mados-welcome.deb > /dev/null )

# mados-desktop (metapackage)
( cd "$ROOT"
  rm -rf /tmp/mados-desktop-build
  mkdir -p /tmp/mados-desktop-build
  cp -r mados-desktop/DEBIAN /tmp/mados-desktop-build/
  find /tmp/mados-desktop-build -type d -exec chmod 755 {} +
  find /tmp/mados-desktop-build -type f -exec chmod 644 {} +
  dpkg-deb --build /tmp/mados-desktop-build mados-desktop.deb > /dev/null )

echo "== Assembling the repository =="

rm -rf "$OUT"
mkdir -p "$OUT"

cp "$ROOT/mados_core/mados-core.deb" \
   "$ROOT/mados-ui/mados-ui.deb" \
   "$ROOT/mados-settings/mados-settings.deb" \
   "$ROOT/mados-update/mados-update.deb" \
   "$ROOT/mados-welcome/mados-welcome.deb" \
   "$ROOT/mados-desktop.deb" \
   "$OUT/"

( cd "$OUT"
  dpkg-scanpackages . /dev/null > Packages
  gzip -9 -k -f Packages
  apt-ftparchive \
      -o APT::FTPArchive::Release::Origin="MadOS" \
      -o APT::FTPArchive::Release::Label="MadOS" \
      -o APT::FTPArchive::Release::Suite="stable" \
      -o APT::FTPArchive::Release::Codename="mados" \
      -o APT::FTPArchive::Release::Architectures="amd64 all" \
      -o APT::FTPArchive::Release::Components="main" \
      -o APT::FTPArchive::Release::Description="MadOS package channel" \
      release . > Release
  touch .nojekyll )

echo "Repository built at $OUT:"
ls -1 "$OUT"

if [ "$1" = "--push" ]; then

    echo "== Publishing to gh-pages =="

    WT="$(mktemp -d)/gh-pages"

    if git -C "$ROOT" ls-remote --exit-code origin gh-pages > /dev/null 2>&1; then
        git -C "$ROOT" fetch origin gh-pages
        git -C "$ROOT" worktree add "$WT" origin/gh-pages > /dev/null
        git -C "$WT" checkout -B gh-pages > /dev/null
    else
        git -C "$ROOT" worktree add --detach "$WT" > /dev/null
        git -C "$WT" checkout --orphan gh-pages > /dev/null
    fi

    find "$WT" -mindepth 1 -maxdepth 1 ! -name ".git" -exec rm -rf {} +
    cp -r "$OUT"/. "$WT"/

    git -C "$WT" add -A

    if git -C "$WT" diff --cached --quiet; then
        echo "No changes to publish."
    else
        git -C "$WT" commit -m "Publish MadOS packages $(date -u +%Y-%m-%dT%H:%M:%SZ)" > /dev/null
        git -C "$WT" push origin gh-pages
        echo "Published."
    fi

    git -C "$ROOT" worktree remove --force "$WT"

fi

echo "Done."

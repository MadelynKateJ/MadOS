#!/bin/bash
# MadOS de-Mint sweep (post-install), as run on the first MadOS install.
#
# Replaces user-visible Linux Mint branding with MadOS while keeping the
# Mint package plumbing that updates depend on. Deliberately KEPT:
#   - mintwelcome (placeholder until mados-welcome is finished)
#   - mintsources, mint-mirrors, linuxmint-keyring (repo plumbing)
#   - ID=linuxmint in /etc/os-release and CODENAME in /etc/linuxmint/info
#     (compatibility anchors; changing the ID broke installs in the past)
#
# ORDER MATTERS: mintwelcome is installed LAST. Installing it earlier and
# then purging its support packages (mint-translations, mint-common)
# drags it back out.
set -x

# --- Identity files ---------------------------------------------------
# NAME/PRETTY_NAME/VERSION become MadOS. ID=linuxmint deliberately stays:
# update tooling finds its repos through it, and changing it broke installs.
sed -i 's|^NAME=.*|NAME="MadOS"|; s|^PRETTY_NAME=.*|PRETTY_NAME="MadOS 0.1.0-alpha"|; s|^VERSION=.*|VERSION="0.1.0-alpha"|' /etc/os-release
sed -i 's|HOME_URL=.*|HOME_URL="https://madoslinux.org/"|; s|SUPPORT_URL=.*|SUPPORT_URL="https://madoslinux.org/"|; s|BUG_REPORT_URL=.*|BUG_REPORT_URL="https://madoslinux.org/"|; s|PRIVACY_POLICY_URL=.*|PRIVACY_POLICY_URL="https://madoslinux.org/"|' /etc/os-release
sed -i 's|DISTRIB_ID=.*|DISTRIB_ID=MadOS|; s|DISTRIB_DESCRIPTION=.*|DISTRIB_DESCRIPTION="MadOS 0.1.0-alpha"|' /etc/lsb-release
printf 'MadOS 0.1.0-alpha \\n \\l\n\n' > /etc/issue
sed -i 's|EDITION=.*|EDITION="Plasma"|; s|DESCRIPTION=.*|DESCRIPTION="MadOS 0.1.0-alpha"|; s|DESKTOP=.*|DESKTOP=KDE|; s|TOOLKIT=.*|TOOLKIT=Qt|; s|GRUB_TITLE=.*|GRUB_TITLE=MadOS|; s|NEW_FEATURES_URL=.*|NEW_FEATURES_URL=https://madoslinux.org/|; s|RELEASE_NOTES_URL=.*|RELEASE_NOTES_URL=https://madoslinux.org/|; s|USER_GUIDE_URL=.*|USER_GUIDE_URL=https://madoslinux.org/|' /etc/linuxmint/info

# --- Firefox partner branding -----------------------------------------
cp /usr/lib/firefox/distribution/distribution.ini /tmp/distribution.ini.mint-backup
cat > /usr/lib/firefox/distribution/distribution.ini <<'INI'
# Partner Distribution Configuration File
[Global]
id=mados-001
version=1.0
about=Mozilla Firefox for MadOS

[Preferences]
app.distributor.channel="alpha"
app.distributor="mados"
app.partner.mados="mados"
app.update.enabled=false
browser.shell.checkDefaultBrowser=false
intl.locale.requested=""
mozilla.partner.id="mados"
browser.backspace_action=0
browser.tabs.inTitlebar=0
INI

# --- Remove Mint-branded apps, artwork, and Cinnamon residue ----------
apt-get purge -y \
  mintupdate mintinstall mintbackup mintchat mintdrivers mintlocale \
  mintmenu mintreport mintstick mint-info mint-info-cinnamon \
  mint-upgrade-info mint-live-session mintsysadm \
  mint-artwork mint-backgrounds-wallpapers mint-themes mint-translations \
  mint-l-theme mint-x-icons mint-y-icons mint-cursor-themes \
  cinnamon-control-center-data cinnamon-desktop-data cinnamon-l10n \
  cinnamon-session-common \
  pix pix-data xed xed-common xed-dbg xreader xreader-common xreader-dbg \
  warpinator thingy webapp-manager hypnotix bulky sticky fingwit \
  ubiquity ubiquity-frontend-gtk ubiquity-slideshow-mint
apt-get autoremove --purge -y

# --- Mint Welcome stays (see header) -----------------------------------
apt-get install -y mintwelcome

# --- Bootloader identity ------------------------------------------------
grub-install --bootloader-id=MadOS /dev/sda
grub-install --target=x86_64-efi --efi-directory=/boot/efi --removable
update-grub

apt-get check

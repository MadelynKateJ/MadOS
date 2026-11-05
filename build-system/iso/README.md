# MadOS Cubic project — what's in here

**Project:** MadOS 0.1.0-alpha, as a Cubic project, assembled 2026-11-03.
**Base:** Linux Mint 22.3 "Zena" Cinnamon (Ubuntu 24.04 noble underneath).

## Layout (standard Cubic)

- `custom-live/` — the Mint ISO tree, copied in unchanged.
- `custom-root/` — the extracted filesystem, **already customized** (below).
- `cubic.conf` — project settings, pointed at MadOS names/versions.

## Already baked into custom-root

- **KDE Plasma 6.8.2** via the KDE neon user repo (Qt 6.11.1, Frameworks 6.31),
  installed with the verified recipe: neon key/repo, full-upgrade first,
  SDDM preselected as display manager, then neon-desktop.
- **All six MadOS packages** from MadOS-src, installed and verified:
  mados-core 0.1, mados-ui 0.2, mados-settings 0.1, mados-update 0.1,
  mados-welcome 0.1, mados-desktop 0.1 (metapackage).
  The .deb files themselves are archived inside the image at
  `/usr/share/mados/debs/`, with `/usr/share/mados/BUILD-INFO.txt`.
- **Identity:** /etc/os-release now reads NAME="MadOS",
  PRETTY_NAME via Cubic's os-release update, VERSION="0.1.0-alpha".
  The ID fields still say linuxmint/ubuntu on purpose, so apt and the
  installer keep their footing. Cinnamon is still installed alongside
  Plasma (nothing was purged); SDDM is the default display manager.

## To finish

1. Open Cubic, choose this directory (/home/maddie/MadOS-Cubic).
   It should recognize the project and let you continue to Generate.
   If it ever offers to re-extract or start over, STOP — the customized
   custom-root is the valuable part. The rebuild recipe is in the
   Custom Linux distro goal runbook.
2. On the Options page, compression was left at Cubic's default.
3. Generate produces `mados-0.1.0-alpha-amd64.iso` here.
4. First test boot checks: the live session should land on Plasma via
   SDDM (Mint's casper picks the default session; if it greets you with
   Cinnamon, that's a one-line SDDM config fix, not a rebuild), and
   mados-welcome / mados-settings / mados-update launch from the menu.

## Decisions still yours

- **Neon base upgrade:** an installed MadOS system will be offered the
  "KDE neon 26.04" base upgrade by neon's notifier. Freeze policy
  undecided — see the goal runbook, gotcha #4.
- **mados-welcome-package.deb** (the alternate welcome build in your
  source folder) was NOT installed; mados-welcome.deb was, because it
  matches the metapackage dependency name.
- Your .git history stayed in ~/MadOS-src (the working copy of the NAS
  folder), not in the image.

## Sakura in the image

`stage-sakura.sh <Cubic project>` copies `branding/sakura/` into the
image at `/usr/share/mados/sakura/` and plants a skel autostart that
runs `apply-sakura.sh` once at each new user's first login (marker:
`~/.config/mados-sakura-done`). The Mint converter uses the same
first-login mechanism (its stage 8b), so a converted Mint and a fresh
ISO install converge on the identical desktop. Run stage-sakura.sh
after customization, before generating the ISO.

## System pieces in the image

`stage-system.sh <Cubic project>` (run after stage-sakura.sh, with
sudo) bakes the system-level half in: the mados SDDM theme and its
config, the virtual-keyboard off switch, the GRUB theme plus its
defaults (Breeze grub.d drop-ins repointed, so the installer's own
update-grub produces a themed boot config), the distro logo, and an
enabled `mados-firstboot.service`. Two pieces cannot be baked
because they need the username the installer creates — the manual
login's HideUsers and the AccountsService avatar — so on an
installed machine's first boot, before the display manager, the
unit runs `branding/sakura/firstboot/mados-firstboot.sh`, which runs
the in-image `sakura-system.sh` once for that user and disables
itself (marker: `/var/lib/mados-firstboot-done`, log:
`/var/log/mados-firstboot.log`). The GRUB theme definition lives in
`branding/sakura/grub-theme.txt`, shared by sakura-system.sh and
stage-system.sh so the two routes cannot drift apart.

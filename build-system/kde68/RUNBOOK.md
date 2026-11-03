# MadOS — KDE Plasma 6.8 force-install: verified process

**Status: PROVEN in a VM, 2026-11-03.** The recipe below took a stock Ubuntu 24.04
(GNOME) system to a booting Plasma 6.8.2 desktop with zero dependency surgery.
The companion script `kde68-cubic.sh` is the same recipe
packaged for Cubic's chroot terminal.

## Verified result (kde-lab VM on the build host)

- plasmashell **6.8.2**, kwin-wayland **6.8.2** (neon release builds)
- KDE Frameworks **6.31.0**, Qt **6.11.1**
- Display manager: SDDM; session: Plasma (Wayland). Booted to desktop and
  visually verified.
- Snapshots on the VM: `pre-kde-surgery` (clean Ubuntu clone) and
  `kde-682-working` (this result), so both ends of the experiment are kept.

## Why "forcible" is the right word

Ubuntu 24.04 (noble) ships Qt 6.4. Plasma 6.8 requires Qt 6.11 + Frameworks 6.30.
No PPA backport crosses that gap. KDE neon is built on the same noble base but
publishes its own Qt/Frameworks/Plasma builds, so adding neon's repo replaces the
entire KDE/Qt library stack with neon's. That swap is the method. It is also how
the earlier MadOS alpha got Plasma 6.7 onto Mint 22.3 (same noble base).

## The method (exact order matters)

1. Add the neon signing key:
   `curl -s http://archive.neon.kde.org/public.key | gpg --dearmor > /usr/share/keyrings/neon-archive-keyring.gpg`
2. Add the repo:
   `deb [signed-by=/usr/share/keyrings/neon-archive-keyring.gpg] http://archive.neon.kde.org/user noble main`
   in `/etc/apt/sources.list.d/neon.list`, then `apt-get update`.
3. **Full-upgrade BEFORE installing the desktop:**
   `apt-get -y full-upgrade` — this raises the shared libraries (Qt above all)
   to neon's versions first. Skipping this step is where the dependency fights
   live; with it, the VM run finished stage after stage at rc=0.
4. Preselect SDDM so the install doesn't coin-flip the display manager:
   `echo "sddm shared/default-x-display-manager select sddm" | debconf-set-selections`
   and write `/usr/bin/sddm` to `/etc/X11/default-display-manager`.
5. `apt-get install -y neon-desktop` — long run, ~700+ packages, several GB.
6. Verify: `plasmashell --version` (see gotcha #1) or
   `dpkg-query -W plasma-workspace kwin-wayland`.

## Gotchas actually observed (not theory)

1. **`plasmashell --version` core-dumps in a headless context.** Run as root over
   SSH with no display, it aborts. It is NOT a broken install. Use
   `QT_QPA_PLATFORM=offscreen plasmashell --version` (prints `plasmashell 6.8.2`)
   or trust the dpkg versions. Matters inside Cubic too: verify by package, not
   by launching the shell in the chroot.
2. **Boot stall from server-base heritage (VM template only).** The Ubuntu server template
   was built server-first, so `systemd-networkd-wait-online` stalled
   boot ~2 minutes while NetworkManager owned the NIC. Fix:
   `systemctl disable` + `mask systemd-networkd-wait-online.service`.
   A Cubic build from a *desktop* ISO won't have this; a server-derived base will.
3. **kwin-x11 stays at 6.7.5 in the repo.** Expected: Plasma 6.8 dropped the X11
   session entirely. Wayland only; X11 apps run through XWayland. MadOS on 6.8
   is a Wayland-only distro by design, not by toggle.
4. **Neon immediately offers a base upgrade to "KDE neon 26.04.1 LTS."** The
   KDED notifier popped it on first desktop boot. For MadOS, decide a freeze
   policy on purpose: an image that silently rebases itself is not an image.
   (Undecided as of this writing — Maddie's call when assembling in Cubic.)
5. SSSD "dependency failed" lines in the boot log are server-base leftovers,
   cosmetic, unrelated to KDE.

## Using it in Cubic (the actual MadOS build)

1. Base ISO choice: Ubuntu 24.04 desktop ISO keeps the installer she wants and
   matches the VM proof 1:1, at the cost of also carrying GNOME unless removed
   in the chroot (`apt-get purge` of the ubuntu-desktop/GNOME stack is optional
   weight loss). Kubuntu 24.04 ISO starts closer to the target (SDDM + Plasma
   5.27 already) and the same script upgrades it — untested path, same base.
2. Create the Cubic project from the ISO; at the chroot terminal page, copy in
   and run `kde68-force-install-for-cubic.sh`. All steps are noninteractive.
3. After the script: the MadOS identity work from the original plan — Plymouth
   boot screen, `/etc/os-release` + `/etc/lsb-release` renaming, hostname,
   default user/session settings. (Hers to art-direct; files live on MadJFiles.)
4. Cubic generates the ISO; test-boot the ISO in a throwaway VM before calling
   it an installer. First-boot checklist: SDDM offers "Plasma (Wayland)" only,
   desktop loads, Discover sees neon + Ubuntu sources, no wait-online stall.
5. Freeze policy for the neon base-upgrade offer (gotcha #4) gets decided
   before the ISO is shared with anyone.

## Addendum, same night: the workstation is assembled

- **Cubic 2026.09.110 installed on kde-lab** (official PPA `ppa:cubic-wizard/release`,
  noble build), launched and screenshot-verified inside the Plasma session —
  see `cubic-installed-lab.png`. It is open at the "Select a project directory"
  page, waiting for a build.
- **Base ISO staged in the VM:** `~/isos/ubuntu-24.04.4-desktop-amd64.iso`
  (SHA256 verified against Ubuntu's published sums before copying in). A copy
  also sits on the the build host's Proxmox ISO shelf.
- Snapshot `cubic-ready` (2026-11-03 02:55) captures this exact state:
  KDE 6.8.2 + Cubic + staged ISO. VM disk: ~15 GB free of 40 after the ISO —
  a Cubic project unpacks several times the ISO size, so watch space during
  the first build (expand the VM disk if it squeezes).

## Addendum 2, same night: the Cubic project is assembled (Mint base)

At Maddie's direction the base switched from Ubuntu to **Linux Mint 22.3**:
Ubuntu 24.04.4's desktop ISO is a layered image (minimal / standard / live
squashfs layers for the new installer) with no classic filesystem.squashfs,
which fights Cubic's customization flow; Mint 22.3 is the classic format,
is noble-based (same neon recipe, unchanged), and is the base her MadOS
alpha actually used.

Built and verified in the kde-lab VM, project at `~/MadOS-Cubic`:

- `custom-live/` = Mint ISO tree; `custom-root/` = extracted filesystem,
  customized via systemd-nspawn (Cubic's own console mechanism).
- Plasma **6.8.2** installed by the recipe above (verified in the image).
- **Her MadOS source folder was copied off MadJFiles** (Personal-Drive /
  Projects / MadOS, 2.5 GB incl. .git) to `~/MadOS-src` — done through her
  own logged-in Dolphin session via KIO, no credentials handled by Kat.
  Payload = per-component .debs + the mados-desktop metapackage
  (Depends: plasma stack, sddm, dolphin, konsole, kate, discover,
  network-manager, pipewire set, mados-core/ui/settings/update/welcome).
  The mados-builder/ subfolder is reference dumps (dpkg -l, unit list,
  KDE config path list) plus empty branding/calamares/hooks scaffolds and
  a live-build.conf — not installable payload.
- All six packages installed into the image and verified by dpkg-query:
  mados-core 0.1, mados-ui 0.2, mados-settings 0.1, mados-update 0.1,
  mados-welcome 0.1, mados-desktop 0.1. Binaries present:
  /usr/bin/madoswelcome, mados-settings, mados-update. The .debs are
  archived in the image at /usr/share/mados/debs/ + BUILD-INFO.txt.
- Identity: os-release NAME="MadOS", VERSION="0.1.0-alpha"; ID fields
  deliberately left linuxmint/ubuntu. Cinnamon remains installed
  alongside Plasma; SDDM set as default display manager.
- `cubic.conf` written by hand from Cubic 2026.09's own configuration
  schema (Project/Original/Custom/Layout/Status/Options) pointing at
  mados-0.1.0-alpha-amd64.iso; a README.md in the project dir covers the
  finish steps and open decisions. VM snapshot `mados-cubic-project`
  preserves the state.

**Lesson (cost one retry):** systemd-nspawn covers the container's /tmp
with a tmpfs. Payload staged in the rootfs's /tmp is invisible inside the
container (apt got a literal unexpanded glob and failed). Stage payload
under the rootfs's /root instead. Kubectx: Cubic project dirs are
custom-live + custom-root + cubic.conf; its extract-root helper is plain
unsquashfs; its console is systemd-nspawn --resolv-conf=bind-host.

## Files

- `kde68-cubic.sh` (this folder) — the recipe, ready to run in Cubic.
- Developed and proven in a throwaway lab VM before it went into the
  image. (SDDM autologin was ON in the lab VM only; not part of the recipe.)

## ISO GENERATED + TEST-BOOTED — Nov 3, 2026 (~04:20 AST)

- File: `mados-0.1.0-alpha-amd64.iso` in this folder (4,927,426,560 bytes, MD5 dc8d45e64a06de1912a9e4371e75cd4b), sidecar `.md5sum` beside it. A copy also sits on the build host's Proxmox ISO shelf for VM use.
- Built with Cubic's Generate pipeline (scripted): squashfs packed with **zstd** (not Cubic's xz default — xz ETA was 70+ min; zstd landed it the same night at ~0.5 GB larger).
- Static verification: volume ID "MadOS 0.1.0-alpha", both BIOS + UEFI El Torito entries, internal md5sums OK, manifest lists all six mados-* packages + plasma-workspace 6.8.2, os-release branded MadOS.
- TEST BOOT (throwaway VM on the build host, destroyed after): boots clean to the SDDM greeter, no kernel panic. TTY login as the live user works. Plasma 6.8 live session runs perfectly: Welcome Center opens as "Welcome to MadOS!" and the desktop carries an "Install MadOS 0.1.0 alpha" icon.
- KNOWN WART: at the greeter, pressing Enter on the preselected session lands on a black screen — the default session SDDM picks first appears to be Cinnamon's experimental Wayland session, which black-screens in a VM. Plasma itself is flawless when started. NEXT-BUILD FIX: an sddm.conf.d drop-in in the image setting the default (and live autologin) session to plasma.desktop. Small change + regenerate; no rebuild from scratch.
- A VM snapshot preserves this exact state.

## FINAL ALPHA BUILD — Nov 3, 2026 (~05:21 AST)

- FINAL ISO: `mados-0.1.0-alpha-amd64.iso`, MD5 **6edf961c86256729f33a776bebfe6bf7**, same 4.9 GB size. This supersedes the earlier builds (dc8d45e6... first write, 87cc956b... autologin attempt).
- LIVE AUTOLOGIN SOLVED, root cause chain: casper's 15autologin writes /etc/sddm.conf at live boot, but only recognises session files under /usr/share/xsessions; Plasma 6.8 ships only a Wayland session, so it wrote an empty Session and SDDM autologin failed. Fix: patched 15autologin inside the image to test /usr/share/wayland-sessions/plasma.desktop, rebuilt the initramfs (the boot-time copy is what runs). One false start: a backup copy of the script left in the casper-bottom folder ALSO executed and overwrote the fix with the empty value; purged and rebuilt clean. Verified in the ISO's own initrd before packing.
- TEST BOOT (throwaway VM, destroyed after): fresh boot goes straight to the Plasma desktop, Welcome Center "Welcome to MadOS!", no greeter interaction. A test VM was subsequently rebooted onto this build and autologs in the same way.
- COPIES: project folder (here), the build host's Proxmox ISO shelf (MD5-verified), and a VM snapshot. A NAS `isos` share copy is still pending (needs the NAS login at the console).
- HOST RAM LESSON (Nov 3): the build host has 32 GB RAM, and the big guests already fill it. Adding test VMs pushed the host into OOM kills, taking the largest guest twice. Do not run extra VMs alongside the big guests without freeing something first.

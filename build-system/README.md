# Building MadOS

How MadOS 0.1.0-alpha was built: a Linux Mint 22.3 ISO, customized
with Cubic's project layout, with KDE Plasma 6.8 from KDE neon
force-installed, the MadOS components added, and the result
rebranded end to end. Surprisingly functional.

## The one-command conversion

`convert-to-mados.sh` replays everything in this folder, in order, on
an already-installed system: fresh Linux Mint 22.x in, MadOS out.

```sh
curl -fsSL https://raw.githubusercontent.com/MadelynKateJ/MadOS/main/build-system/convert-to-mados.sh | sudo bash
```

Run standalone like that, the script downloads this repo itself and
works from the copy. Run from a clone
(`sudo bash build-system/convert-to-mados.sh`) it uses the local
files. Stages: neon Plasma 6.8, the six component .debs from the
v0.1.0-alpha release, SDDM + Plasma session with Cinnamon removed,
the de-Mint sweep, Plymouth, hostname, and the neofetch cat for the
invoking user. Log at /var/log/mados-convert.log; one reboot at the
end.

**End-to-end tested 2026-11-03:** a fresh Linux Mint 22.3 install in a
throwaway VM, converted with the one line above, rebooted into SDDM +
Plasma 6.8.2 with all six components installed, the MadOS identity
throughout, and the cat in neofetch. One fix came out of the test:
demint.sh now writes the Firefox partner config last, because the
neon-registered Mozilla repo can upgrade Firefox mid-sweep and
restore the stock file.

## Pipeline

1. **Extract the base ISO** — `iso/extract-mint.sh` builds the Cubic
   project skeleton (custom-live + custom-root) from the Mint 22.3
   Cinnamon ISO, the same way Cubic itself does.
2. **Customize the rootfs** — `iso/customize.sh` enters the rootfs
   with systemd-nspawn (Cubic's own mechanism) and runs
   `iso/in-root.sh`, which:
   - force-installs KDE Plasma 6.8 (see `kde68/`; order matters:
     neon repo, then `apt full-upgrade`, then preselect SDDM, then
     `neon-desktop`),
   - brands `/etc/os-release` as MadOS (NAME/PRETTY_NAME/VERSION;
     `ID=linuxmint` is deliberately kept, see Notes),
   - installs the six MadOS component .debs.
   `iso/debs-fix.sh` handles the in-image .deb archive placement.
3. **Fix live-session autologin** — `iso/casper-autologin-fix.sh`
   patches casper's 15autologin to find Plasma's Wayland session,
   then `iso/initramfs-rebuild.sh` rebuilds the initramfs. The
   initramfs rebuild must happen *after* any casper change, and
   backup copies of casper scripts must live *outside* the rootfs
   tree: casper-bottom executes every file in its folder, backups
   included.
4. **Generate the ISO** — `iso/generate.sh` plus `iso/write-iso.py`
   (zstd compression, volume ID from `iso/cubic.conf`, xorriso using
   the original ISO's El Torito parameters with the volume ID
   substituted; never shell-eval the template).
5. **Branding, on the installed system** — `branding/plymouth/`
   (boot splash), `branding/demint.sh` (the post-install de-Mint
   sweep: identity files, Firefox partner config, GRUB renamed to
   MadOS, Mint-branded apps out, Mint Welcome kept until
   mados-welcome is finished), `branding/neofetch/` (the cat).

## kde68/

`kde68.sh` is the interactive lab version of the Plasma 6.8 install;
`kde68-cubic.sh` is the variant that runs inside the Cubic rootfs.
`RUNBOOK.md` is the full write-up, gotchas included (headless
plasmashell version checks, the networkd wait-online boot stall,
and the neon base-upgrade question).

## Notes and standing decisions

- **`ID=linuxmint` stays.** Tools use it to find the right update
  repositories, and changing it broke installs during development.
  Everything a user can *see* says MadOS; the ID is plumbing.
- **Cinnamon is still in the alpha live image** alongside Plasma.
  The first install needed a post-install fix to default to Plasma
  and purge Cinnamon. Making Plasma the installed default at build
  time (and deciding Cinnamon's fate in the image) is a known TODO
  for the next build.
- **The ISO is 4.93 GB**, over GitHub's 2 GB release-attachment
  limit, so releases here carry the .deb packages and checksums;
  ISO distribution gets its own shelf later.
- Pipeline scripts and this documentation were developed with Kat
  during the 0.1.0-alpha build sessions in Madelyn's home lab.

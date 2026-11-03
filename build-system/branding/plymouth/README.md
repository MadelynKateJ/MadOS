# MadOS Plymouth theme

The boot splash: the MadOS neon sign (`splash.png`, rendered from
`../logo-clean.jpg`) on black, via a Plymouth script theme.

Files:
- `mados.plymouth` — theme descriptor (script module)
- `mados.script` — paints the background black and centers the splash
- `splash.png` — 1920x1080 splash image

Install (as done on the first MadOS install):

```sh
cp -r mados /usr/share/plymouth/themes/
chmod -R a+rX /usr/share/plymouth/themes/mados
update-alternatives --install /usr/share/plymouth/themes/default.plymouth \
  default.plymouth /usr/share/plymouth/themes/mados/mados.plymouth 100
update-alternatives --set default.plymouth \
  /usr/share/plymouth/themes/mados/mados.plymouth
update-initramfs -u
```

Note: `plymouth-set-default-theme` is not packaged on the Mint base;
the update-alternatives route above is the Debian way and works.
Also disable the leftover `casper-md5check.service` on installed
systems (it fails looking for the live ISO's checksums).

# 🌸 MadOS

MadOS is a modern Linux desktop experience built on Linux Mint and KDE Neon.

Its default look is Sakura: a blossom wallpaper, blush-pink colors,
Candy icons, and window buttons shaped like little flowers — a bud to
minimize, a half-open blossom to maximize, a full bloom to close.

## Current Components

- mados_core
  - Shared framework
  - Package management
  - Launchers
  - System utilities

- mados-welcome
  - First-run experience
  - Software recommendations
  - System shortcuts

- mados-update
  - Native update manager
  - Install selected updates
  - Install all updates

- mados-ui
  - Shared widgets
  - Shared styling
  - Theme assets

## Building

```bash
./build.sh
```

## Running

```bash
./run.sh
```

Current Status:

✅ Alpha 0.1

## Turn a fresh Mint install into MadOS

Install Linux Mint 22.x, then run one line:

```sh
curl -fsSL https://raw.githubusercontent.com/MadelynKateJ/MadOS/main/build-system/convert-to-mados.sh | sudo bash
```

It installs KDE Plasma 6.8, the MadOS components, the boot splash and
branding, and removes the Mint identity (Mint Welcome stays until
mados-welcome is finished). Details: `build-system/convert-to-mados.sh`.

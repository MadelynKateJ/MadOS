# MadOS neofetch

`cat.txt` is the ASCII cat used as the neofetch logo (the big sitting
cat, pink). The earlier candidates (an outline cat, a logo-face
replica, a chibi) live in the project history; this is the keeper.

Install:

```sh
mkdir -p ~/.config/neofetch
cp cat.txt ~/.config/neofetch/cat.txt
```

In `~/.config/neofetch/config.conf` set:

```
image_backend="ascii"
image_source="$HOME/.config/neofetch/cat.txt"
ascii_colors=(5)
```

Color 5 (magenta) is the MadOS pink. The `${c1}` prefixes in cat.txt
are neofetch's color placeholders and are required.

Note: fastfetch is not in the Mint repositories; neofetch is the
fetch tool on MadOS for now.

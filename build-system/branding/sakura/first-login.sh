#!/bin/bash
# MadOS Sakura first-login apply: runs the full Sakura setup once,
# the first time a new user logs into Plasma, then never again.
# Used by the Mint converter and baked into the MadOS ISO (via
# /etc/skel autostart) so every route lands on the same desktop.
[ -f "$HOME/.config/mados-sakura-done" ] && exit 0
sleep 8
SAKURA_DIR="$HOME/.local/share/mados/sakura"
[ -d "$SAKURA_DIR" ] || SAKURA_DIR="/usr/share/mados/sakura"
mkdir -p "$HOME/.cache"
bash "$SAKURA_DIR/apply-sakura.sh" >> "$HOME/.cache/mados-sakura.log" 2>&1
touch "$HOME/.config/mados-sakura-done"

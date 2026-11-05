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
# Only stamp the done-marker when the apply actually succeeded.
# (Before 2026-11-04 the marker was touched unconditionally, so a
# half-finished apply would never be retried on later logins.)
if bash "$SAKURA_DIR/apply-sakura.sh" >> "$HOME/.cache/mados-sakura.log" 2>&1; then
    touch "$HOME/.config/mados-sakura-done"
else
    echo "$(date): apply-sakura failed, will retry next login" \
        >> "$HOME/.cache/mados-sakura.log"
fi

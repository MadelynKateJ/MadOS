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
    # One-time relogin: the apply writes the finished config
    # (window effects included) into a session that is already
    # running, and a running KWin does not reliably load newly
    # enabled effects from a reconfigure alone. The first
    # converter-built machine proved it: config perfect, no
    # wobble, no blur, until a fresh login. So finish the job
    # properly: log out once, and the next login starts the
    # compositor and shell on the finished config. Guarded by
    # its own marker so it can only ever happen once.
    if [ ! -f "$HOME/.config/mados-sakura-relogin" ]; then
        touch "$HOME/.config/mados-sakura-relogin"
        notify-send -a "MadOS" -i preferences-desktop-theme \
            "Your desktop is ready" \
            "MadOS finished setting everything up. Logging out once so every effect loads cleanly. Just log back in." \
            2>/dev/null || true
        sleep 6
        qdbus6 org.kde.Shutdown /Shutdown org.kde.Shutdown.logout 2>/dev/null \
            || loginctl terminate-session "$XDG_SESSION_ID" 2>/dev/null \
            || true
    fi
else
    echo "$(date): apply-sakura failed, will retry next login" \
        >> "$HOME/.cache/mados-sakura.log"
fi

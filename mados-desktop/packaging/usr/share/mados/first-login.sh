#!/bin/bash
# MadOS Sakura first-login apply (system copy, shipped in the
# mados-desktop package and started by the autostart entry in
# /etc/xdg/autostart). Runs the full Sakura setup once, the first
# time a new user logs into Plasma, then never again.
#
# Because the trigger is system-wide rather than seeded into one
# user's home, it reaches every account however the account or its
# home was created: installer, converter, useradd, or a domain
# login whose home pam_mkhomedir just made. Every route lands on
# the same desktop.
[ -f "$HOME/.config/mados-sakura-done" ] && exit 0
mkdir -p "$HOME/.cache" "$HOME/.config"

# Serialize: two triggers (this autostart, an ISO-seeded per-user
# autostart) can fire on the same first login. Whoever gets the
# lock applies; the other finds the done marker afterwards.
exec 9>"$HOME/.cache/mados-sakura.lock"
flock -n 9 || exit 0
[ -f "$HOME/.config/mados-sakura-done" ] && exit 0

sleep 8
SAKURA_DIR="$HOME/.local/share/mados/sakura"
[ -d "$SAKURA_DIR" ] || SAKURA_DIR="/usr/share/mados/sakura"
LOG="$HOME/.cache/mados-sakura.log"

# Neofetch cat for this user. (The converter does this for its one
# target user in stage 7; a first-login runner has to do it for
# every user.) Writes the cat and the three config lines that use
# it; harmless if neofetch itself is not installed yet.
if [ -f /usr/share/mados/neofetch/cat.txt ]; then
    mkdir -p "$HOME/.config/neofetch"
    cp /usr/share/mados/neofetch/cat.txt "$HOME/.config/neofetch/cat.txt"
    CONF="$HOME/.config/neofetch/config.conf"
    [ -f "$CONF" ] || neofetch --print_config > "$CONF" 2>/dev/null || touch "$CONF"
    grep -q '^image_backend' "$CONF" \
        && sed -i 's/^image_backend=.*/image_backend="ascii"/' "$CONF" \
        || echo 'image_backend="ascii"' >> "$CONF"
    grep -q '^image_source' "$CONF" \
        && sed -i "s|^image_source=.*|image_source=\"$HOME/.config/neofetch/cat.txt\"|" "$CONF" \
        || echo "image_source=\"$HOME/.config/neofetch/cat.txt\"" >> "$CONF"
    grep -q '^ascii_colors' "$CONF" \
        && sed -i 's/^ascii_colors=.*/ascii_colors=(5)/' "$CONF" \
        || echo 'ascii_colors=(5)' >> "$CONF"
fi

# Only stamp the done-marker when the apply actually succeeded.
# (Before 2026-11-04 the marker was touched unconditionally, so a
# half-finished apply would never be retried on later logins.)
if [ -f "$SAKURA_DIR/apply-sakura.sh" ] \
    && bash "$SAKURA_DIR/apply-sakura.sh" >> "$LOG" 2>&1; then
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
    echo "$(date): apply-sakura failed or missing, will retry next login" \
        >> "$LOG"
fi

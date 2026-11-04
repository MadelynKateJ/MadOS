#!/bin/bash
# ISO variant: the Sakura tree ships in /usr/share/mados/sakura;
# copy the runner into place is unnecessary, this file is installed
# to ~/.local/share/mados/first-login.sh by the skel autostart Exec
# below pointing straight at the system copy.
[ -f "$HOME/.config/mados-sakura-done" ] && exit 0
sleep 8
mkdir -p "$HOME/.cache"
bash "/usr/share/mados/sakura/apply-sakura.sh" >> "$HOME/.cache/mados-sakura.log" 2>&1
touch "$HOME/.config/mados-sakura-done"

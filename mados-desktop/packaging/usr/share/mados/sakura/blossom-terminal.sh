#!/bin/bash
# A second Konsole profile with the sakura wallpaper inside the
# terminal. The main MadOSSakura scheme stays at Opacity=0; this
# profile has its own scheme copy at 0.85 and does NOT become the
# default.
K="$HOME/.local/share/konsole"
sed 's/^Opacity=0$/Opacity=0.85/' "$K/MadOSSakura.colorscheme" > "$K/MadOSSakuraBlossom.colorscheme"
sed -i 's/^Name=MadOS Sakura$/Name=MadOS Sakura Blossom/' "$K/MadOSSakuraBlossom.colorscheme"
cat > "$K/Sakura Blossom.profile" <<'PROF'
[Appearance]
ColorScheme=MadOSSakuraBlossom
Wallpaper=/home/mad/Pictures/mados-sakura-wallpaper.jpg
[General]
Name=Sakura Blossom
PROF
sed -i "s|^Wallpaper=.*|Wallpaper=$HOME/Pictures/mados-sakura-wallpaper.jpg|" "$K/Sakura Blossom.profile"

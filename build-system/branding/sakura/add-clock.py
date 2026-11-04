#!/usr/bin/env python3
"""Add a digital clock applet to the desktop containment, if absent.
The desktop containment is the one owning a [Wallpaper] section."""
import configparser, os, re

P = os.path.expanduser("~/.config/plasma-org.kde.plasma.desktop-appletsrc")
cp = configparser.RawConfigParser()
cp.optionxform = str
cp.read(P)
sections = cp.sections()

desktop = None
for s in sections:
    m = re.fullmatch(r"Containments\]\[(\d+)\]\[Wallpaper\].*", s)
    if m:
        desktop = m.group(1)
        break
if desktop is None:
    print("no desktop containment found")
    raise SystemExit

prefix = f"Containments][{desktop}][Applets]["
for s in sections:
    if s.startswith(prefix) and cp.get(s, "plugin", fallback="") == "org.kde.plasma.digitalclock":
        print("desktop clock already present")
        raise SystemExit

ids = []
for s in sections:
    m = re.search(r"\[Applets\]\[(\d+)\]$", s)
    if m:
        ids.append(int(m.group(1)))
new_id = (max(ids) + 1) if ids else 100
block = (
    f"\n[Containments][{desktop}][Applets][{new_id}]\n"
    "immutability=1\n"
    "plugin=org.kde.plasma.digitalclock\n"
    f"\n[Containments][{desktop}][Applets][{new_id}][Configuration][General]\n"
    "showDate=true\n"
    "showSeconds=false\n"
)
with open(P, "a") as f:
    f.write(block)
print(f"clock applet {new_id} added to desktop containment {desktop}")

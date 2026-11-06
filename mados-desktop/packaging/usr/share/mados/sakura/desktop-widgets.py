#!/usr/bin/env python3
"""MadOS Sakura desktop widgets: clock, MKJ sticky note (pink),
media frame (the ASCII cat), media controller, weather.

Run with plasmashell STOPPED (its exit-save overwrites external
edits). Two hard-won lessons live here:
- configparser section names have NO trailing bracket:
  "Containments][1][Applets][200" — a regex demanding the final
  "]" silently matches nothing.
- The notes applet keeps its text in a rich-text document under
  ~/.local/share/plasma_notes/<noteId>, not in the config; the
  config only carries color/fontSize.
- MediaFrame wants [Configuration][Paths] pathList, a string list
  of JSON objects: {"path": "<url>", "type": "file"} with the
  commas backslash-escaped for KConfig.
"""
import configparser, glob, os, re

HOME = os.path.expanduser("~")
P = os.path.join(HOME, ".config/plasma-org.kde.plasma.desktop-appletsrc")
cp = configparser.RawConfigParser(); cp.optionxform = str; cp.read(P)
sections = cp.sections()

desktop = None
for s in sections:
    m = re.search(r"Containments\]\[(\d+)\]\[Wallpaper\]", s)
    if m:
        desktop = m.group(1); break
if desktop is None:
    raise SystemExit("no desktop containment")

prefix = f"Containments][{desktop}][Applets]["
existing = {cp.get(s, "plugin", fallback=""): re.search(r"\[Applets\]\[(\d+)$", s).group(1)
            for s in sections if s.startswith(prefix) and re.search(r"\[Applets\]\[(\d+)$", s)}
ids = [int(v) for v in existing.values()]
next_id = (max(ids) + 1) if ids else 200

def add(plugin, cfg):
    global next_id
    if plugin in existing:
        return existing[plugin]
    block = (f"\n[Containments][{desktop}][Applets][{next_id}]\n"
             f"immutability=1\nplugin={plugin}\n")
    for group, items in cfg.items():
        block += f"\n[Containments][{desktop}][Applets][{next_id}][Configuration][{group}]\n"
        for k, v in items:
            block += f"{k}={v}\n"
    with open(P, "a") as f:
        f.write(block)
    existing[plugin] = str(next_id)
    next_id += 1
    return existing[plugin]

def setkey(app, group, key, value):
    s = f"Containments][{desktop}][Applets][{app}][Configuration][{group}"
    if not cp.has_section(s):
        cp.add_section(s)
    cp.set(s, key, value)

add("org.kde.plasma.digitalclock", {"General": [("showDate", "true")]})
note = add("org.kde.plasma.notes", {"General": [("noteText", "MKJ")]})
setkey(note, "General", "color", "pink")
setkey(note, "General", "fontSize", "28")
frame = add("org.kde.plasma.mediaframe", {})
setkey(frame, "Paths", "pathList",
       '{"path":"file://' + HOME + '/cat.png"\\,"type":"file"}')
add("org.kde.plasma.mediacontroller", {})
add("org.kde.plasma.weather", {})
with open(P, "w") as f:
    cp.write(f, space_around_delimiters=False)

# The note's words live in its document file.
for nf in glob.glob(os.path.join(HOME, ".local/share/plasma_notes/*")):
    if os.path.isdir(nf):
        continue
    doc = open(nf).read()
    doc = doc.replace("font-size:11pt", "font-size:28pt")
    doc = re.sub(r'<p style="-qt-paragraph-type:empty;[^>]*><br /></p>',
                 '<p style=" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;">MKJ</p>',
                 doc)
    open(nf, "w").write(doc)
print("widgets done")

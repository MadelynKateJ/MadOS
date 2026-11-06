#!/usr/bin/env python3
"""KWin window rule: Dolphin slightly translucent (85% active)."""
import configparser, os
p = os.path.expanduser("~/.config/kwinrulesrc")
cp = configparser.RawConfigParser(); cp.optionxform = str
cp.read(p)
if not cp.has_section("General"):
    cp.add_section("General"); cp.set("General", "count", "0")
if not any(cp.has_option(s, "wmclass") and cp.get(s, "wmclass") == "dolphin" for s in cp.sections()):
    count = int(cp.get("General", "count", fallback="0")) + 1
    g = str(count)
    cp.add_section(g)
    for k, v in [("Description", "Ghost Dolphin (Sakura)"), ("wmclass", "dolphin"),
                 ("wmclasscomplete", "true"), ("wmclassmatch", "0"),
                 ("opacityactive", "85"), ("opacityactiverule", "2"),
                 ("opacityinactive", "78"), ("opacityinactiverule", "2")]:
        cp.set(g, k, v)
    cp.set("General", "count", str(count))
    with open(p, "w") as f:
        cp.write(f, space_around_delimiters=False)
    print("dolphin rule added")

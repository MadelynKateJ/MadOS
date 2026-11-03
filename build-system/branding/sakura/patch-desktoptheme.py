#!/usr/bin/env python3
"""Turn the stock Breeze desktop theme ('default') into MadOS Sakura.

The frame artwork lives in <g id="..."> groups whose CHILD shapes carry
class="ColorScheme-Background" + fill:currentColor (they normally take
the color scheme's background, which is too pale for a themed menu).
We hard-paint those child shapes sakura pink and tuck a small blossom
cluster into the dialog center group. Rebuilds from the pristine system
copy every run, validates the XML before writing, and leaves any file
it cannot patch safely untouched."""
import gzip, json, os, re, shutil
import xml.dom.minidom

SRC = "/usr/share/plasma/desktoptheme/default"
DST = os.path.expanduser("~/.local/share/plasma/desktoptheme/MadOSSakura")
DIALOG_PINK = "#F9A8D4"
PANEL_PINK = "#FBDCEB"

def blossom(cx, cy, r, fill, op):
    parts = [f'<g transform="translate({cx},{cy})">']
    for k in range(5):
        parts.append(
            f'<ellipse cx="0" cy="{-r*0.55:.2f}" rx="{r*0.44:.2f}" ry="{r*0.62:.2f}" '
            f'fill="{fill}" fill-opacity="{op}" transform="rotate({k*72})"/>')
    parts.append(f'<circle r="{r*0.24:.2f}" fill="#D6336C" fill-opacity="{min(op+0.2,0.85)}"/>')
    parts.append(f'<circle r="{r*0.09:.2f}" fill="#FFD166"/>')
    parts.append("</g>")
    return "".join(parts)

def motif():
    return (
        blossom(26.5, 7.5, 2.3, "#EC4899", 0.50)
        + blossom(19.0, 15.0, 1.5, "#EC4899", 0.42)
        + blossom(28.5, 19.5, 1.25, "#F472B6", 0.45)
        + '<ellipse cx="22.5" cy="24.5" rx="0.8" ry="1.2" fill="#F472B6" fill-opacity="0.35" transform="rotate(30 22.5 24.5)"/>'
        + '<ellipse cx="15.5" cy="8.0" rx="0.7" ry="1.1" fill="#F472B6" fill-opacity="0.3" transform="rotate(-20 15.5 8)"/>'
    )

def patch_svgz(path, pink, with_blossoms):
    with gzip.open(path, "rt", encoding="utf-8") as f:
        svg = f.read()
    original = svg

    def fix_tag(m):
        tag = m.group(0)
        tag = tag.replace("fill:currentColor", f"fill:{pink}")
        tag = tag.replace('fill="currentColor"', f'fill="{pink}"')
        return tag

    # Every element bound to the scheme background gets the hard pink.
    svg = re.sub(r"<[^>]*ColorScheme-Background[^>]*>", fix_tag, svg)
    if with_blossoms:
        m = re.search(r'<g\s[^>]*\bid="center"[^>]*>', svg)
        if m:
            svg = svg[:m.end()] + motif() + svg[m.end():]
    if svg == original:
        print("no-change:", path)
        return False
    try:
        xml.dom.minidom.parseString(svg)
    except Exception as e:
        print("XML-INVALID, left unpatched:", path, e)
        return False
    with gzip.open(path, "wt", encoding="utf-8") as f:
        f.write(svg)
    return True

def main():
    if os.path.isdir(DST):
        shutil.rmtree(DST)
    shutil.copytree(SRC, DST)
    mp = os.path.join(DST, "metadata.json")
    with open(mp) as f:
        meta = json.load(f)
    meta["KPlugin"]["Id"] = "MadOSSakura"
    meta["KPlugin"]["Name"] = "MadOS Sakura"
    meta["KPlugin"]["Description"] = "Breeze, blushed: sakura-pink dialogs and panels with blossoms tucked in the corner."
    for k in list(meta["KPlugin"].keys()):
        if k.startswith(("Name[", "Description[")):
            del meta["KPlugin"][k]
    meta["KPlugin"]["Authors"] = [{"Name": "Madelyn", "Email": "madelyn@madoslinux.org"}]
    with open(mp, "w") as f:
        json.dump(meta, f, indent=4)
    ok = 0
    for variant in ("", "opaque", "solid", "translucent"):
        p = os.path.join(DST, variant, "dialogs", "background.svgz")
        if os.path.isfile(p) and patch_svgz(p, DIALOG_PINK, True):
            ok += 1
            print("patched dialog:", variant or "root")
        p = os.path.join(DST, variant, "widgets", "panel-background.svgz")
        if os.path.isfile(p) and patch_svgz(p, PANEL_PINK, False):
            ok += 1
            print("patched panel:", variant or "root")
    print("patched OK:", ok)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Write the MadOS ISO: rebuild xorriso command from the ORIGINAL ISO's own
El Torito report (Cubic's method), changing only the volume id.
Avoids shell eval/quoting entirely by generating a runner script whose
template lines are inserted verbatim."""
import subprocess, sys

ISO_SRC = "/home/maddie/isos/linuxmint-22.3-cinnamon-64bit.iso"
DISK = "/home/maddie/MadOS-Cubic/custom-disk"
OUT = "/home/maddie/MadOS-Cubic/mados-0.1.0-alpha-amd64.iso"
VOLID = "MadOS 0.1.0-alpha"

report = subprocess.run(
    ["xorriso", "-indev", ISO_SRC, "-report_el_torito", "as_mkisofs"],
    capture_output=True, text=True).stdout

lines = []
for raw in report.splitlines():
    line = raw.strip()
    if not line:
        continue
    if line.startswith("-V "):
        line = f"-V '{VOLID}'"
    lines.append(line)

if not any(l.startswith("-b ") for l in lines):
    print("FATAL: no boot image arg in template:", lines)
    sys.exit(1)

with open("/root/run-xorriso.sh", "w") as f:
    f.write("#!/bin/bash\n")
    f.write(f"cd {DISK} || exit 1\n")
    f.write("xorriso -as mkisofs -r -J -joliet-long -l -iso-level 3 \\\n")
    for line in lines:
        f.write(f"  {line} \\\n")
    f.write(f"  -o {OUT} .\n")
print("runner written with", len(lines), "template args")

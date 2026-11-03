#!/bin/bash
# MadOS ISO generation, mirroring Cubic 2026.09's Generate pipeline step for step.
exec > /root/mados-generate.log 2>&1
set -x
PROJ=/home/maddie/MadOS-Cubic
ROOT=$PROJ/custom-root
LIVE=$PROJ/custom-live
DISK=$PROJ/custom-disk
ISO_SRC=/home/maddie/isos/linuxmint-22.3-cinnamon-64bit.iso
OUT=$PROJ/mados-0.1.0-alpha-amd64.iso
VOLID='MadOS 0.1.0-alpha'
DISKNAME='MadOS 0.1.0-alpha - Release amd64'

# --- 0. Clean build scaffolding out of the image rootfs -----------------------
rm -rf "$ROOT/root/mados-debs" "$ROOT/root/mados-in-root.sh" \
       "$ROOT/root/mados-customize.log" "$ROOT/root/mados-debs-in.sh" \
       "$ROOT/root/mados-debs-in.log" "$ROOT/tmp/mados-debs"

# --- 1. custom-disk = fresh copy of the ISO tree ------------------------------
rm -rf "$DISK"
cp -a "$LIVE" "$DISK"

# --- 2. Kernel sync: rootfs /boot pair over casper's --------------------------
KV=$(ls "$ROOT"/boot/vmlinuz-* | sort -V | tail -1)
KI=$(ls "$ROOT"/boot/initrd.img-* | sort -V | tail -1)
echo "rootfs kernel: $KV / $KI"
cp "$KV" "$DISK/casper/vmlinuz"
cp "$KI" "$DISK/casper/initrd.lz"

# --- 3. Manifest from the rootfs dpkg database --------------------------------
# Mirror the original manifest's separator style.
SEP=$(head -1 "$LIVE/casper/filesystem.manifest" | grep -qP '\t' && echo '\t' || echo ' ')
dpkg-query --admindir="$ROOT/var/lib/dpkg" -W -f="\${Package}${SEP}\${Version}\n" 2>/dev/null \
  | sort > "$DISK/casper/filesystem.manifest"
# manifest-remove = original remove list, filtered to still-installed packages
awk '{print $1}' "$DISK/casper/filesystem.manifest" | sort -u > /tmp/mados-installed.txt
awk 'NR==FNR{inst[$1]=1; next} ($1 in inst)' /tmp/mados-installed.txt \
  "$LIVE/casper/filesystem.manifest-remove" > "$DISK/casper/filesystem.manifest-remove" || true

# --- 4. Squashfs (Cubic's own compress-root helper, zstd) ---------------------
# zstd, not Cubic's xz default: xz ETA was 70+ min on 2026-11-03; zstd landed
# the same night at ~0.5 GB larger ISO. Both are first-class Cubic options.
rm -f "$DISK/casper/filesystem.squashfs"
/usr/share/cubic/commands/compress-root "$ROOT" "$DISK/casper/filesystem.squashfs" zstd

# --- 5. filesystem.size = byte size of the rootfs -----------------------------
du -sb "$ROOT" | cut -f1 > "$DISK/casper/filesystem.size"

# --- 6. .disk/info + README.diskdefines ---------------------------------------
mkdir -p "$DISK/.disk"
echo "$DISKNAME ($(date +%Y%m%d))" > "$DISK/.disk/info"
{
  echo "#define DISKNAME  $DISKNAME"
  echo "#define DISKNOTE  Generated using Cubic version 2026.09.110 on $(date '+%Y-%m-%d %H:%M:%S') based on linuxmint-22.3-cinnamon-64bit.iso"
  echo "#define ARCH  amd64"
  echo "#define ARCHamd64  1"
  grep -vE 'DISKNAME|DISKNOTE|ARCH' "$LIVE/README.diskdefines" 2>/dev/null || true
} > "$DISK/README.diskdefines"

# --- 7. Boot/catalog paths from the ORIGINAL ISO's report (for step 8) --------
# The full boot template is consumed by /root/mados-write-iso.py in step 9,
# which reads the report itself. NEVER sed/eval the template in shell: the
# 2026-11-03 first write died on quote mangling in exactly that approach.
RAW=$(xorriso -indev "$ISO_SRC" -report_el_torito as_mkisofs 2>/dev/null)

# --- 8. md5sum.txt (exclude itself + eltorito boot/catalog files) -------------
BOOTIMG=$(echo "$RAW" | grep -oE -- "-b '[^']*'" | head -1 | sed "s/-b '//; s/'$//; s|^/||")
BOOTCAT=$(echo "$RAW" | grep -oE -- "-c '[^']*'" | head -1 | sed "s/-c '//; s/'$//; s|^/||")
echo "boot image: $BOOTIMG ; catalog: $BOOTCAT"
( cd "$DISK" && find . -type f \
    ! -path './md5sum.txt' \
    ! -path "./$BOOTIMG" \
    ! -path "./$BOOTCAT" \
    -print0 | sort -zf | tr '\0' '\n' \
    | while IFS= read -r f; do md5sum "$f"; done ) > "$DISK/md5sum.txt"

# --- 9. Write the ISO ----------------------------------------------------------
# mados-write-iso.py rebuilds the xorriso command from the ORIGINAL ISO's own
# El Torito report (Cubic's method, only the volume id changed) and writes it
# verbatim into /root/run-xorriso.sh. No shell eval of template text, ever.
python3 /root/mados-write-iso.py
/root/run-xorriso.sh
ls -la "$OUT"

# --- 10. ISO checksum sidecar (Cubic does the same) ----------------------------
( cd "$PROJ" && md5sum "$(basename "$OUT")" > "$(basename "$OUT" .iso).md5sum" )
df -h / | tail -1
echo MADOS-GENERATE-DONE

#!/bin/bash
# Builds the LAN Helper Tesla overlay inside the devkitPro MSYS2 shell.
# Invoked by build.bat in this same folder (and usable standalone from msys2):
#   bash build.sh [target] [jobs] [--dryrun]
#     target  all (default) | dist | clean
#
# libtesla is header-only and comes from the flat sibling ../tesla-lib --
# there is no nested libs/libtesla submodule (see this repo's flat-lib layout).

source /etc/profile.d/devkit-env.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Point at the flat-cloned libnx fork, not devkitPro's stock system libnx --
# the latter is stale and lacks API additions this repo's projects rely on.
# Matches the root Makefile's own override.
export LIBNX="$SCRIPT_DIR/../libnx/nx"

TARGET="${1:-all}"
JOBS="${2:-2}"
DRYRUN=""
[ "${3}" = "--dryrun" ] && DRYRUN="-n"

echo "DEVKITPRO=$DEVKITPRO"
echo "Target=$TARGET Jobs=$JOBS DryRun=${DRYRUN:-no} CWD=$(pwd)"

if [ "$TARGET" = "clean" ]; then
    make clean
    exit $?
fi

MAKE_TARGET="$TARGET"
[ "$TARGET" = "dist" ] && MAKE_TARGET="all"

make $DRYRUN -j"$JOBS" "$MAKE_TARGET"
STATUS=$?

if [ $STATUS -eq 0 ] && [ -z "$DRYRUN" ]; then
    echo "== Build ok: lanhelper.ovl =="
    ls -la lanhelper.ovl 2>/dev/null

    # Overlay-only project: the zip's top level mirrors the SD card root, so
    # extracting it onto an SD card root installs it. See PACKAGING.md.
    # Installed as LANHelper.ovl (not lanhelper.ovl) to overwrite the copy
    # already on the card rather than adding a second Tesla menu entry.
    if [ "$TARGET" = "dist" ] && [ -f lanhelper.ovl ]; then
        ZIPS_DIR="$SCRIPT_DIR/../_ZIPS_"
        SDCARD_DIR="$SCRIPT_DIR/../_SDCARD_/lanhelper"
        mkdir -p "$ZIPS_DIR"
        rm -rf "$SDCARD_DIR"
        mkdir -p "$SDCARD_DIR/switch/.overlays"
        cp lanhelper.ovl "$SDCARD_DIR/switch/.overlays/LANHelper.ovl"
        (cd "$SDCARD_DIR" && zip -rq "$ZIPS_DIR/lanhelper-release.zip" ./*)
        echo "== Packaged: $ZIPS_DIR/lanhelper-release.zip =="
        echo "== Extracted: $SDCARD_DIR =="
    fi
fi

exit $STATUS

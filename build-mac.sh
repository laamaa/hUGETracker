#!/bin/bash
set -xeuo pipefail

LAZARUS_DIR="/Users/jonne/Applications/lazarus"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_MODE="Production Mac"
EXTRA_OPT="-k-ld_classic"

cd "$PROJECT_DIR"

# ── Register package dependencies ────────────────────────────
echo "==> Registering packages..."
lazbuild --lazarusdir="$LAZARUS_DIR" --add-package-link src/rackctls/RackCtlsPkg.lpk
lazbuild --lazarusdir="$LAZARUS_DIR" --add-package-link src/bgrabitmap/bgrabitmap/bgrabitmappack.lpk

# ── Build ────────────────────────────────────────────────────
echo "==> Building hUGETracker..."
lazbuild --lazarusdir="$LAZARUS_DIR" src/hUGETracker.lpi --build-mode="$BUILD_MODE" --opt="$EXTRA_OPT"

echo "==> Building uge2source..."
lazbuild --lazarusdir="$LAZARUS_DIR" src/uge2source/uge2source.lpi --build-mode=Release --opt="$EXTRA_OPT"

# ── Compile halt.gb ──────────────────────────────────────────
echo "==> Compiling halt.gb..."
OBJ=$(mktemp)
HDOBJ=$(mktemp)
trap 'rm -f "$OBJ" "$HDOBJ"' EXIT

rgbasm -E -I src/hUGEDriver -o "$HDOBJ" src/hUGEDriver/hUGEDriver.asm
rgbasm -I src/hUGEDriver/include -o "$OBJ" src/halt.asm

STAGING=$(mktemp -d)
rgblink -o "$STAGING/halt.gb" -n "$STAGING/halt.sym" "$OBJ" "$HDOBJ"
rgbfix -vp0xFF "$STAGING/halt.gb"

# ── Package .app bundle ──────────────────────────────────────
echo "==> Packaging .app bundle..."
PACKAGING="$PROJECT_DIR/packaging"
rm -rf "$PACKAGING"
mkdir -p "$PACKAGING"

# Copy the .app bundle produced by lazbuild
cp -Rp src/Release/hUGETracker.app "$PACKAGING/"

APP="$PACKAGING/hUGETracker.app"
CONTENTS="$APP/Contents"
RESOURCES="$CONTENTS/Resources"
MACOS="$CONTENTS/MacOS"

# Resources
cp graphics/hUGETracker.icns "$RESOURCES/"
cp "$STAGING/halt.gb" "$STAGING/halt.sym" "$RESOURCES/"
cp fonts/PixeliteTTF.ttf "$RESOURCES/"
cp -R src/hUGEDriver "$RESOURCES/hUGEDriver"

# Symlink RGBDS tools into MacOS dir
for tool in rgbasm rgblink rgbfix; do
    TOOL_PATH=$(which "$tool" 2>/dev/null || true)
    if [ -n "$TOOL_PATH" ]; then
        cp "$TOOL_PATH" "$MACOS/$tool"
    else
        echo "Warning: $tool not found in PATH, skipping"
    fi
done

# Copy ffmpeg if available
FFMPEG_PATH=$(which ffmpeg 2>/dev/null || true)
if [ -n "$FFMPEG_PATH" ]; then
    cp "$FFMPEG_PATH" "$MACOS/ffmpeg"
else
    echo "Warning: ffmpeg not found in PATH, skipping"
fi

# Add icon to Info.plist
ed "$CONTENTS/Info.plist" <<'END'
5i
<key>CFBundleIconFile</key>
<string>hUGETracker.icns</string>
.
w
q
END

# Extra files alongside the .app
cp -R "$PROJECT_DIR/sample-songs" "$PACKAGING/"
cp -R "$PROJECT_DIR/keymaps" "$PACKAGING/"

mv src/Release/hUGETracker "$MACOS/"

# ── Create zip ───────────────────────────────────────────────
#echo "==> Creating zip..."
#cd "$PACKAGING"
#zip -r "$PROJECT_DIR/hUGETracker-mac.zip" . -x 'hUGETracker'
#cd "$PROJECT_DIR"

#echo "==> Done! Output: hUGETracker-mac.zip"
echo "    App bundle: $PACKAGING/hUGETracker.app"

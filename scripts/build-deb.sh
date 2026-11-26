#!/usr/bin/env bash
# Build the .deb:  scripts/build-deb.sh [VERSION]   -> dist/aoe-linux_VERSION_all.deb
# The package is tiny (script + icons + menu entry). Wine and cnc-ddraw are
# downloaded on the first run into the user's home, pinned by sha256.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
VER=${1:-$(sed -n 's/^VERSION="\(.*\)"/\1/p' "$ROOT/aoe-linux")}
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
P="$T/aoe-linux_${VER}_all"

install -Dm755 "$ROOT/aoe-linux" "$P/usr/bin/aoe-linux"
install -Dm644 "$ROOT/assets/aoe-linux.desktop" "$P/usr/share/applications/aoe-linux.desktop"
sed -i "s|^Exec=aoe-linux|Exec=/usr/bin/aoe-linux|" "$P/usr/share/applications/aoe-linux.desktop"
for s in 16 24 32 48 64 128 256 512; do
    install -Dm644 "$ROOT/assets/icons/$s.png" "$P/usr/share/icons/hicolor/${s}x${s}/apps/aoe-linux.png"
done
install -Dm644 "$ROOT/assets/aoe-linux.svg" "$P/usr/share/icons/hicolor/scalable/apps/aoe-linux.svg"
install -Dm644 "$ROOT/LICENSE" "$P/usr/share/doc/aoe-linux/copyright"

mkdir -p "$P/DEBIAN"
cat >"$P/DEBIAN/control" <<EOF
Package: aoe-linux
Version: $VER
Section: games
Priority: optional
Architecture: all
Maintainer: Hoang Duc Long <hoangduclongg@gmail.com>
Homepage: https://github.com/DucLong06/aoe-linux
Depends: bash, curl, xz-utils, unzip, ca-certificates, libx11-6, libxext6, libxrender1, libxrandr2, libxi6, libxcursor1, libxcomposite1, libxinerama1, libfreetype6, libfontconfig1, libgl1, libpulse0, libgnutls30t64 | libgnutls30, fonts-liberation
Recommends: zenity, libgl1-mesa-dri, xdg-utils, pkexec | policykit-1, iproute2, libglib2.0-bin
Description: Age of Empires (I, Rise of Rome, II) on Linux in one click
 Sets up a portable Wine (WoW64, no 32-bit system libraries needed) and
 cnc-ddraw for sharp borderless fullscreen, imports the game files you
 provide, and adds an "Age of Empires" entry to the app menu.
 No Bottles, no Flatpak, no gamescope. Game files are not included.
EOF
mkdir -p "$ROOT/dist"
dpkg-deb --build --root-owner-group "$P" "$ROOT/dist/" >/dev/null
ls -1 "$ROOT/dist/aoe-linux_${VER}_all.deb"

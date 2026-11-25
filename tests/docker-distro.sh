#!/usr/bin/env bash
# Fresh-distro test: install aoe-linux in a bare container, import the game zip,
# play it under Xvfb for 35 s and save a screenshot.
#   Ubuntu/Debian images: installs the newest dist/aoe-linux_*_all.deb with apt.
#   Arch images: installs the runtime libraries with pacman, then install.sh (no sudo).
#
#   tests/docker-distro.sh GAME.zip IMAGE      e.g. ubuntu:26.04, archlinux:latest
#   -> dist/distro-<image>/shot.png + log.txt; prints GAME_ALIVE=yes|no
# Behind a proxy, export https_proxy/http_proxy first (passed to the container).
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
ZIP=$(readlink -f "${1:?game zip}")
IMG=${2:?image, e.g. ubuntu:26.04 or archlinux:latest}
DEB=$(find "$ROOT/dist" -maxdepth 1 -name 'aoe-linux_*_all.deb' -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)
case "$IMG" in arch*) ;; *) [ -n "$DEB" ] || { echo "build the .deb first: scripts/build-deb.sh" >&2; exit 1; } ;; esac
OUT="$ROOT/dist/distro-${IMG//[:\/]/-}"; rm -rf "$OUT"; mkdir -p "$OUT"
PROXY=${https_proxy:-${HTTPS_PROXY:-}}

docker run --rm \
    -e http_proxy="$PROXY" -e https_proxy="$PROXY" -e HTTP_PROXY="$PROXY" -e HTTPS_PROXY="$PROXY" \
    ${DEB:+-v "$DEB:/pkg/aoe-linux.deb:ro"} -v "$ZIP:/pkg/game.zip:ro" -v "$ROOT:/src:ro" -v "$OUT:/out" \
    "$IMG" bash -c '
set -e
chmod 1777 /out   # the test user is not always uid 1000
grep PRETTY_NAME /etc/os-release
if command -v pacman >/dev/null; then
    pacman -Syu --noconfirm --needed bash curl xz unzip ca-certificates which \
        libx11 libxext libxrender libxrandr libxi libxcursor libxcomposite libxinerama \
        freetype2 fontconfig mesa libpulse gnutls ttf-liberation \
        xorg-server-xvfb xorg-xwd procps-ng >/dev/null
    useradd -m player
    su player -c "sh /src/install.sh" | tail -3
    BIN=/home/player/.local/bin/aoe-linux
else
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq >/dev/null
    apt-get install -y -qq /pkg/aoe-linux.deb xvfb x11-apps procps >/dev/null 2>&1 \
        || { apt-get install -y /pkg/aoe-linux.deb 2>&1 | tail -15; exit 1; }
    dpkg -s aoe-linux | grep -E "^(Status|Version)"
    useradd -m player
    BIN=/usr/bin/aoe-linux
fi
su player -c "cd ~ && AOE_NOGUI=1 $BIN setup /pkg/game.zip </dev/null" 2>&1 | tail -4
su player -c "AOE_NOGUI=1 $BIN doctor" || true
su player -c "
    Xvfb :1 -screen 0 1920x1080x24 >/dev/null 2>&1 &
    sleep 2; export DISPLAY=:1 GTK_IM_MODULE=ibus XMODIFIERS=@im=ibus
    cd ~; AOE_NOGUI=1 $BIN play </dev/null >/dev/null 2>&1 &
    sleep 35
    xwd -root -display :1 > /out/shot.xwd
    p=\$(pgrep -f -i \"[e]mpiresx.exe\" | head -1)
    if [ -n \"\$p\" ]; then echo GAME_ALIVE=yes; tr \"\\0\" \"\\n\" < /proc/\$p/environ | grep -E \"^(XMODIFIERS|GTK_IM_MODULE)=\" || echo GTK_IM_MODULE=unset
    else echo GAME_ALIVE=no; tail -20 ~/.local/share/aoe-linux/last-run.log; fi
"
' 2>&1 | tee "$OUT/log.txt"
if [ -s "$OUT/shot.xwd" ] && command -v ffmpeg >/dev/null; then
    ffmpeg -loglevel error -y -i "$OUT/shot.xwd" "$OUT/shot.png" && rm -f "$OUT/shot.xwd"
fi
ls "$OUT"

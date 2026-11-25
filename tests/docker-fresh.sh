#!/usr/bin/env bash
# Fresh-machine test: install the .deb in a bare ubuntu container, set the game up
# from a zip, play it under Xvfb and save screenshots.
#   tests/docker-fresh.sh GAME.zip [ubuntu:24.04]     -> dist/fresh-*/shot-*.png
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
ZIP=$(readlink -f "${1:?game zip}")
IMG=${2:-ubuntu:24.04}
DEB=$(ls -1t "$ROOT"/dist/aoe-linux_*_all.deb | head -1)
OUT="$ROOT/dist/fresh-${IMG//[:\/]/-}"; mkdir -p "$OUT"
docker run --rm \
    -e http_proxy="${http_proxy:-${HTTP_PROXY:-}}" -e https_proxy="${https_proxy:-${HTTPS_PROXY:-}}" \
    -v "$DEB:/pkg/aoe-linux.deb:ro" -v "$ZIP:/pkg/game.zip:ro" -v "$ROOT/tests:/tests:ro" -v "$OUT:/out" \
    "$IMG" bash -c '
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null
apt-get install -y -qq /pkg/aoe-linux.deb xvfb x11-utils ffmpeg >/dev/null 2>&1
useradd -m player
su player -c "cd ~ && AOE_NOGUI=1 aoe-linux setup /pkg/game.zip </dev/null" 2>&1 | tail -8
su player -c "AOE_NOGUI=1 aoe-linux doctor" || true
su player -c "cd ~ && xvfb-run -a -s \"-screen 0 1920x1080x24\" bash /tests/smoke.sh /tmp/shots" 2>&1 | grep -E "alive|rror" || true
cp /tmp/shots/*.png /out/
'
ls -la "$OUT"

#!/usr/bin/env bash
# Smoke test: play the installed game under a virtual X screen and take screenshots.
#   tests/smoke.sh OUTDIR [GAME] [MODE]     (run inside: xvfb-run -a -s "-screen 0 1920x1080x24")
# Uses the same AOE_HOME / XDG_* environment as the install under test.
set -u
out=${1:?outdir}; game=${2:-}; mode=${3:-play}
here=$(cd "$(dirname "$0")/.." && pwd)
bin=${AOE_BIN:-$here/aoe-linux}; [ -x "$bin" ] || bin=$(command -v aoe-linux)
mkdir -p "$out"
size=$(xdpyinfo 2>/dev/null | awk '/dimensions:/{print $2}'); size=${size:-1920x1080}
if [ "$mode" = windowed ]; then "$bin" windowed "$game" & else "$bin" play "$game" & fi
pid=$!
for t in 20 35; do
    sleep $(( t - ${prev:-0} )); prev=$t
    ffmpeg -loglevel error -y -f x11grab -draw_mouse 0 -video_size "$size" -i "$DISPLAY" -frames:v 1 "$out/shot-${t}s.png"
done
alive=no; kill -0 $pid 2>/dev/null && alive=yes
echo "game-alive-after-35s=$alive"
data="${AOE_HOME:-$HOME/.local/share/aoe-linux}"
for ws in "$data"/wine-*/bin/wineserver; do WINEPREFIX="$data/prefix" "$ws" -k 2>/dev/null; done
wait $pid 2>/dev/null
exit 0

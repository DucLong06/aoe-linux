#!/bin/sh
# aoe-linux installer: no sudo, everything under ~/.local.
#
#   curl -fsSL https://raw.githubusercontent.com/DucLong06/aoe-linux/main/install.sh | sh
#   curl -fsSL .../install.sh | sh -s -- --game ~/Downloads/aoe.zip
#   sh install.sh [--game ZIP|FOLDER|URL] [--lang en|vi] [--uninstall]
#
# Installs the aoe-linux command, its icon and the "Age of Empires" menu entry.
# With --game it also sets the game up right away; otherwise the first click on
# the menu entry asks where the game is. Run it again to update.
set -eu

REPO="DucLong06/aoe-linux"
BRANCH="${AOE_BRANCH:-main}"
PREFIX="${AOE_PREFIX:-$HOME/.local}"
GAME=""
LANG_ARG=""
UNINSTALL=0

while [ $# -gt 0 ]; do
    case "$1" in
        --game) GAME="${2:-}"; shift ;;
        --game=*) GAME="${1#--game=}" ;;
        --lang) LANG_ARG="${2:-}"; shift ;;
        --lang=*) LANG_ARG="${1#--lang=}" ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help) sed -n '2,10p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "install.sh: unknown option $1 / tuỳ chọn không hợp lệ $1" >&2; exit 2 ;;
    esac
    shift
done

L=en
for v in "$LANG_ARG" "${AOE_LANG:-}" "${LC_ALL:-}" "${LC_MESSAGES:-}" "${LANG:-}"; do
    case "$v" in "") ;; vi*|VI*) L="vi"; break ;; *) L="en"; break ;; esac
done
[ -n "$LANG_ARG" ] && export AOE_LANG="$LANG_ARG"

say() { if [ "$L" = vi ]; then f=$2; else f=$1; fi; shift 2
        # shellcheck disable=SC2059
        printf "$f\n" "$@"; }
die() { say "$@" >&2; exit 1; }

BIN="$PREFIX/bin"
APPS="$PREFIX/share/applications"
ICONS="$PREFIX/share/icons/hicolor"

if [ "$UNINSTALL" = 1 ]; then
    if [ -x "$BIN/aoe-linux" ]; then "$BIN/aoe-linux" uninstall </dev/tty || true; fi
    rm -f "$BIN/aoe-linux" "$APPS"/aoe-linux*.desktop "$ICONS"/*/apps/aoe-linux.png "$ICONS/scalable/apps/aoe-linux.svg"
    command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" 2>/dev/null || true
    say "aoe-linux removed." "Đã gỡ aoe-linux."
    exit 0
fi

[ "$(uname -s)" = Linux ] && [ "$(uname -m)" = x86_64 ] || die "Linux x86_64 only." "Chỉ chạy trên Linux x86_64."
for c in curl tar xz unzip sha256sum; do
    command -v "$c" >/dev/null 2>&1 || die "Missing %s: sudo apt install curl xz-utils unzip" "Thiếu %s: sudo apt install curl xz-utils unzip" "$c"
done

# Source: this checkout when run from one, else the repo tarball.
SRC=""
here=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
if [ -n "$here" ] && [ -f "$here/aoe-linux" ] && [ -f "$here/assets/aoe-linux.desktop" ]; then
    SRC=$here
else
    TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
    say "Downloading aoe-linux..." "Đang tải aoe-linux..."
    n=0
    until curl -fsSL --retry 3 "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" -o "$TMP/src.tgz"; do
        n=$((n + 1)); [ $n -ge 5 ] && die "Download failed, check the network." "Tải thất bại, kiểm tra mạng."
        sleep 3
    done
    tar -xzf "$TMP/src.tgz" -C "$TMP"
    SRC=$(find "$TMP" -maxdepth 1 -type d -name 'aoe-linux-*' | head -1)
fi

mkdir -p "$BIN" "$APPS"
install -m755 "$SRC/aoe-linux" "$BIN/aoe-linux"
for s in 16 24 32 48 64 128 256 512; do
    install -Dm644 "$SRC/assets/icons/$s.png" "$ICONS/${s}x${s}/apps/aoe-linux.png"
done
install -Dm644 "$SRC/assets/aoe-linux.svg" "$ICONS/scalable/apps/aoe-linux.svg"
# Menu launchers may not have ~/.local/bin on PATH: use the absolute path
sed "s|^Exec=aoe-linux|Exec=$BIN/aoe-linux|" "$SRC/assets/aoe-linux.desktop" >"$APPS/aoe-linux.desktop"
command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$APPS" 2>/dev/null || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -q -t -f "$ICONS" 2>/dev/null || true

say "Installed: %s" "Đã cài: %s" "$BIN/aoe-linux"
command -v zenity >/dev/null 2>&1 || say "Tip: sudo apt install zenity  (windows for the first-run setup)" \
                                         "Mẹo: sudo apt install zenity  (hiện cửa sổ khi cài lần đầu)"
fc-list 2>/dev/null | grep -qi 'Liberation Sans' || say "Tip: sudo apt install fonts-liberation  (game fonts)" \
                                                        "Mẹo: sudo apt install fonts-liberation  (font cho game)"

if [ -n "$GAME" ]; then
    "$BIN/aoe-linux" setup "$GAME"
else
    say "Open \"Age of Empires\" from the app menu: the first click asks where the game is." \
        "Mở \"Age of Empires\" trong menu ứng dụng: lần đầu bấm sẽ hỏi game nằm ở đâu."
    say "Or from the terminal: aoe-linux setup ~/Downloads/game.zip" \
        "Hoặc từ terminal: aoe-linux setup ~/Downloads/game.zip"
fi

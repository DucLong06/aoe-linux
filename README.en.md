<p align="center">
  <img src="docs/icon.png" alt="aoe-linux: a gold castle battlement and the letters AoE on dark red" width="160">
</p>

<p align="center"><b>Age of Empires on Linux, in one click</b> 🇻🇳<br>
Age of Empires, Rise of Rome and Age of Empires II on Ubuntu: no Bottles, no
Flatpak, no gamescope, no sudo, no step-by-step clicking.</p>

<p align="center">Made in Vietnam, where the game is still called Đế Chế</p>

<p align="center"><a href="README.md">Tiếng Việt</a> · <a href="README.en.md">English</a></p>

[![CI](https://github.com/DucLong06/aoe-linux/actions/workflows/ci.yml/badge.svg)](https://github.com/DucLong06/aoe-linux/actions/workflows/ci.yml)

![A game of Age of Empires running on Linux: town center, villagers, the resource bar reading Wood 200 Food 200, fullscreen with 4:3 kept](docs/img/ingame.jpg)

## Install

Three steps. **Only step 1 uses the Google Drive link**; nothing after it downloads the game.

### Step 1: download the game first (in your browser)

aoe-linux **ships no game and never downloads it on its own** (the game is
copyrighted). Get the game zip first:

- Link: https://drive.google.com/file/d/1-9N9TB4zAQj8ssXu_eYm8x4yH-ATPbwa/view
- File: `game-de-che-1.zip`, about 51 MB (Age of Empires: Rise of Rome, a repack)
- sha256: `e109cf5dfe227813b3b90fb787dd4d9189c2da51db0e536e2405af761e9d4fbc`

If Google says it "can't scan this file for viruses", click **Download anyway**.
Keep the file in **Downloads** under its own name and aoe-linux finds it by
itself. Check it was not altered:

```sh
sha256sum ~/Downloads/game-de-che-1.zip
# must print: e109cf5dfe227813b3b90fb787dd4d9189c2da51db0e536e2405af761e9d4fbc
```

Already have your own copy (zip, folder, or an old Bottles install)? Skip this step.

### Step 2: install aoe-linux

This only installs the `aoe-linux` command, the icon and the menu entry. No game,
no Wine yet.

```sh
wget https://github.com/DucLong06/aoe-linux/releases/latest/download/aoe-linux_all.deb
sudo apt install ./aoe-linux_all.deb
```

Without sudo, into `~/.local`:

```sh
curl -fsSL https://raw.githubusercontent.com/DucLong06/aoe-linux/main/install.sh | sh
```

### Step 3: open the game

Open **Age of Empires** from the app menu. The first click:

1. Looks for a copy you already have: the `game-de-che-1.zip` from step 1 (or a
   `.zip` named like `aoe`, `empire`, `de-che` in Downloads), or a Bottles
   install. It asks "Use it?"; click **Use it**.
2. Otherwise asks where the game is: a **.zip file**, an unpacked **folder**,
   or a **download link** (Google Drive, Dropbox and OneDrive share links work
   as-is). A link is only fetched when you paste it yourself.
3. Downloads Wine (~95 MB from GitHub, once, resumes when the network drops),
   builds the environment, copies the game in and starts it. About 1–2 minutes.

After that a click starts the game. The terminal works too:

```sh
aoe-linux setup ~/Downloads/game-de-che-1.zip   # import the game
aoe-linux                                       # play
```

The zip in Downloads is only needed for this import; delete it afterwards, the
game is unpacked elsewhere (see below).

### Is it a virus?

The zip holds old Windows `.exe` files: the game (`Empiresx.exe`, `Empires.exe`),
the DirectPlay installer `Dplay60a.exe`, and a few tools bundled with the repack
(a no-CD patch, a windowed-mode helper). Windows antivirus often flags no-CD
patches. aoe-linux runs **two files** only: `Empiresx.exe` (the game) and
`Dplay60a.exe` (to unpack DirectPlay), both inside Wine, in its own
`~/.local/share/aoe-linux` folder, without sudo and without touching system
files. Check the sha256 as in step 1 to be sure the file is the original, or use
your own copy.

## Where things are after install

Apart from the command and the icon, everything lives in your home folder (`~`):

| What | Path |
|---|---|
| `aoe-linux` command | `/usr/bin/aoe-linux` (.deb) or `~/.local/bin/aoe-linux` (no-sudo install) |
| Icon and menu entry | `/usr/share/applications/aoe-linux.desktop` or `~/.local/share/applications/` |
| Game zip from step 1 | `~/Downloads/game-de-che-1.zip` (safe to delete after install) |
| Wine | `~/.local/share/aoe-linux/wine-11.22/` |
| Virtual Windows C: drive | `~/.local/share/aoe-linux/prefix/` |
| **Game** | `~/.local/share/aoe-linux/prefix/drive_c/Games/aoe1/` (AoE II: `.../Games/aoe2/`) |
| **Saves** | `~/.local/share/aoe-linux/prefix/drive_c/Games/aoe1/savegame/` |
| aoe-linux's own downloads (Wine, cnc-ddraw, a game from a pasted link) | `~/.cache/aoe-linux/` |
| Settings (proxy) | `~/.config/aoe-linux/config` |
| Last run log | `~/.local/share/aoe-linux/last-run.log` |

- `aoe-linux doctor` prints these paths for your machine.
- `~/.cache/aoe-linux` (~150 MB) can be deleted once the game is set up.
- Open the game folder: right-click the icon → **Open game folder**, or `aoe-linux folder`.

## LAN play

Everyone installs aoe-linux and joins the same network. aoe-linux installs
Microsoft's DirectPlay from the game's own `Dplay60a.exe` (Wine's DirectPlay cannot
host a game), pre-selects TCP/IP and fills in the player name.

- **Host:** Multiplayer → OK → Create → name the game → OK → pick the map → tick
  I'm Ready! → Start Game once everyone is in and ready.
- **Join:** Multiplayer → OK → Show Games → leave the address box **empty** and
  press OK (searches the LAN) → pick the game → Join → tick I'm Ready!
- "Internet TCP/IP Connection For DirectPlay" is the right connection type for LAN
  too. Game not found: type the host's IP (`aoe-linux lan` shows it). Rename:
  `aoe-linux name "New name"`. With ufw on: allow 47624/tcp and 2300:2400 tcp+udp.
- Tested: two fresh installs in docker on one network, host + LAN search + join,
  both reached the game.

To share another copy (AoE II, a modded build) with friends, upload the zip to
Google Drive and share it as "Anyone with the link" with the **Viewer** role (not
Editor: anyone with the link could replace the file). They download it in a
browser like step 1, or paste the link into the first-run dialog
(or `aoe-linux setup "<link>"`).

## Behind a proxy

The first run downloads Wine and cnc-ddraw from GitHub. On a network that needs a
proxy (replace `http://proxy.example.com:8080` with yours):

```sh
export https_proxy=http://proxy.example.com:8080 http_proxy=http://proxy.example.com:8080
wget https://github.com/DucLong06/aoe-linux/releases/latest/download/aoe-linux_all.deb
sudo -E apt install ./aoe-linux_all.deb      # -E passes the proxy to apt
aoe-linux proxy http://proxy.example.com:8080   # menu launches do not see https_proxy: save it once
```

`aoe-linux proxy` shows the saved proxy, `aoe-linux proxy off` removes it. If
`sudo -E` is not enough, set `Acquire::http::Proxy` and `Acquire::https::Proxy` in
`/etc/apt/apt.conf.d/95proxy`. Downloads resume after a dropped connection and are
checked by sha256.

## What it replaces

| Old way (Bottles) | aoe-linux |
|---|---|
| Install Flatpak, Flathub, Bottles, gamescope (over 1 GB) | One small package; portable Wine ~95 MB on first run |
| Create a bottle, disable DXVK/VKD3D, pick Windows 7 | Done for you |
| Install allfonts, cnc-ddraw, directplay by hand | cnc-ddraw built in; Arial mapped to Liberation; DirectPlay from the game's `Dplay60a.exe` |
| Copy the game into the virtual C: drive, set the working directory | Pick the zip; registry and paths are written for you |
| Tune gamescope 1024x768 → 1920x1080 + FSR | cnc-ddraw: borderless fullscreen, 4:3 kept, FSR sharpening |
| Type `NOSTARTUP` to skip the intro | Added for you |
| Game jumps to the portrait monitor | No monitor mode switch; if it still lands wrong, `Super+Shift+←/→` |

Wine is the WoW64 build, so 32-bit games run without any i386 system libraries.

## Right-click menu

Right-click the icon in the dock or the app menu:

- **Play in a window**: `Alt+Enter` also toggles in game.
- **Display settings**: cnc-ddraw's settings window (shader, aspect, renderer).
- **Open game folder**: saves, maps, campaigns, mods.
- **Import the game again**: switch to another copy; your saves are kept.

The main icon plays Rise of Rome. If the folder also holds Age of Empires II, it
gets its own menu entry. The right-click menu also has **LAN play: how to + this
machine's address**.

## Commands

| Command | Does |
|---|---|
| `aoe-linux` | Play (Rise of Rome by default) |
| `aoe-linux play aoe2 \| aoe2x` | Play Age of Empires II / The Conquerors |
| `aoe-linux windowed` | Play in a window |
| `aoe-linux setup [ZIP\|FOLDER\|URL]` | Import or re-import the game |
| `aoe-linux display` | Display settings |
| `aoe-linux folder` | Open the game folder |
| `aoe-linux doctor` | Check the machine and the install when something breaks |
| `aoe-linux proxy [URL\|off]` | Save, show or remove the download proxy |
| `aoe-linux lan` | LAN how-to and this machine's address |
| `aoe-linux name ["Name"]` | Show or set the player name |
| `aoe-linux repair` | Redo DirectPlay, registry and menu entries |
| `aoe-linux uninstall` | Remove the game, saves and Wine (asks first) |

Paths: see [Where things are after install](#where-things-are-after-install). To remove it all: `aoe-linux uninstall`, then
`sudo apt remove aoe-linux` (or `sh install.sh --uninstall` for the no-sudo install).
Messages follow your system language (English or Vietnamese); force one with `AOE_LANG=en`.

## Troubleshooting

- Run `aoe-linux doctor`: Wine version, missing libraries, fonts, GPU and the
  tail of the last run's log (`~/.local/share/aoe-linux/last-run.log`).
- Boxes instead of text in game: `sudo apt install fonts-liberation`.
- Nothing appears on the first click: `sudo apt install zenity`, or set up from
  a terminal with `aoe-linux setup <file.zip>`.
- `sha256sum` of the game zip differs from step 1: the download is broken or not
  the original. Delete it and download again; still different, report it in Issues.
- A pasted Drive link says "The link gives a web page": the file is not shared
  publicly, or Google Drive hit its daily download limit. Download it in a
  browser as in step 1 and pick **A .zip file**.
- "Cannot unpack ... game-de-che-1.zip": you run aoe-linux 0.1.2 or older, which
  mistook zips re-packed on Windows for broken ones. Update to 0.1.3 (install the
  latest `.deb`) and run it again.
- Chinese repacks show one garbled credits line on the main menu. It comes from
  the repack and does not affect play.

## Tested

Ubuntu 24.04 with Rise of Rome: imported from the `game-de-che-1.zip` of step 1, main menu, Single Player →
Random Map → Start Game, in game with legible text. The `.deb` is install-tested
on a blank Ubuntu 24.04 in docker. Age of Empires II is supported but not yet
tested with real game files. Report problems in [Issues](https://github.com/DucLong06/aoe-linux/issues).

## Built on

- [Wine](https://www.winehq.org/), portable build by [Kron4ek/Wine-Builds](https://github.com/Kron4ek/Wine-Builds)
- [cnc-ddraw](https://github.com/FunkyFr3sh/cnc-ddraw) by FunkyFr3sh
- Both are pinned by version and sha256 in the script; every download is verified.

MIT licensed. Age of Empires is a trademark of Microsoft; this project is not
affiliated with Microsoft.

<p align="center">Thanks to <a href="https://github.com/NousResearch/hermes-agent">Hermes</a> and <a href="https://claude.ai">Claude</a> for building this project together 🇻🇳</p>

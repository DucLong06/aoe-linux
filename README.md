<p align="center">
  <img src="docs/icon.png" alt="aoe-linux: bức tường thành vàng và chữ AoE trên nền đỏ sẫm" width="160">
</p>

<p align="center"><b>Đế Chế trên Linux</b>: bấm một lần là chơi Age of Empires 🇻🇳<br>
Age of Empires, Rise of Rome và Age of Empires II chạy trên Ubuntu mà không cần
Bottles, Flatpak hay gamescope, không cần sudo, không phải bấm tay từng bước.</p>

<p align="center"><a href="README.md">Tiếng Việt</a> · <a href="README.en.md">English</a></p>

[![CI](https://github.com/DucLong06/aoe-linux/actions/workflows/ci.yml/badge.svg)](https://github.com/DucLong06/aoe-linux/actions/workflows/ci.yml)

![Một trận Age of Empires đang chơi trên Linux: nhà chính, dân làng, thanh tài nguyên Gỗ 200 Thức ăn 200, toàn màn hình giữ tỉ lệ 4:3](docs/img/ingame.jpg)

## Cài đặt

```sh
wget https://github.com/DucLong06/aoe-linux/releases/latest/download/aoe-linux_all.deb
sudo apt install ./aoe-linux_all.deb
```

Không có sudo thì cài vào `~/.local`:

```sh
curl -fsSL https://raw.githubusercontent.com/DucLong06/aoe-linux/main/install.sh | sh
```

Sau đó mở **Age of Empires** trong menu ứng dụng. Lần bấm đầu tiên:

1. Tự tìm game có sẵn trên máy: bản đã cài bằng Bottles theo hướng dẫn cũ, hoặc
   file `.zip` có tên kiểu `aoe`, `empire`, `de-che` trong Downloads.
2. Không thấy thì hỏi game ở đâu: **file .zip**, **thư mục** đã giải nén, hoặc
   **link tải**.
3. Tải Wine (~95 MB, một lần, mạng đứt thì tự tải tiếp), dựng môi trường, chép
   game vào, rồi mở game. Mất khoảng 1–2 phút.

Từ lần sau bấm là vào game. Dùng terminal cũng được:

```sh
aoe-linux setup ~/Downloads/game-de-che.zip   # nhập game
aoe-linux                                      # chơi
```

> Repo không chứa file game (game có bản quyền). Bạn dùng bản game của mình.

## Mạng cần proxy (công ty, trường học)

Lần đầu chạy, aoe-linux cần tải Wine và cnc-ddraw từ GitHub. Nếu mạng phải đi qua
proxy thì làm thêm các bước sau (thay `http://proxy.congty.vn:8080` bằng proxy
của bạn):

**1. Cài gói `.deb` qua proxy**

```sh
export https_proxy=http://proxy.congty.vn:8080 http_proxy=http://proxy.congty.vn:8080
wget https://github.com/DucLong06/aoe-linux/releases/latest/download/aoe-linux_all.deb
sudo -E apt install ./aoe-linux_all.deb      # -E để apt dùng proxy vừa đặt
```

`sudo -E` không ăn thì đặt proxy cho apt một lần:

```sh
echo 'Acquire::http::Proxy "http://proxy.congty.vn:8080"; Acquire::https::Proxy "http://proxy.congty.vn:8080";' \
  | sudo tee /etc/apt/apt.conf.d/95proxy
```

Cài không sudo cũng vậy: `export https_proxy=...` rồi chạy dòng `curl ... | sh`.

**2. Lưu proxy cho aoe-linux**

Icon trong menu không đọc biến `https_proxy` của terminal, nên phải lưu proxy lại
một lần:

```sh
aoe-linux proxy http://proxy.congty.vn:8080   # lưu
aoe-linux proxy                               # xem đang dùng proxy nào
aoe-linux proxy off                           # bỏ proxy (khi về mạng nhà)
```

Proxy được lưu ở `~/.config/aoe-linux/config`. Wine chỉ tải một lần, sau đó chơi
không cần mạng. Riêng chơi LAN thì không đi qua proxy.

Mạng chập chờn cũng không sao: file tải dở được giữ lại, chạy lại là tải tiếp, và
mọi file đều được kiểm tra sha256 trước khi dùng.

## Có gì khác so với cách cài cũ

| Cách cũ (Bottles) | aoe-linux |
|---|---|
| Cài Flatpak, Flathub, Bottles, gamescope (hơn 1 GB) | Một gói nhỏ, Wine portable ~95 MB tải lần đầu |
| Tạo bottle, tắt DXVK/VKD3D, chọn Windows 7 | Tự làm |
| Cài allfonts, cnc-ddraw, directplay bằng tay | cnc-ddraw cài sẵn; font Arial thay bằng Liberation; DirectPlay dùng bản có sẵn của Wine |
| Chép game vào ổ C ảo, trỏ Working Directory | Chọn file zip là xong, registry và đường dẫn tự ghi |
| Chỉnh gamescope 1024x768 → 1920x1080 + FSR | cnc-ddraw: toàn màn hình không viền, giữ 4:3, làm nét FSR |
| Nhập `NOSTARTUP` để bỏ intro | Tự thêm |
| Game nhảy sang màn hình dọc | Không đổi độ phân giải màn hình; vẫn lệch thì `Super+Shift+←/→` |

Wine dùng bản WoW64 nên chạy được game 32-bit mà máy không cần thư viện i386.

## Menu chuột phải

Bấm chuột phải vào icon trên dock hoặc trong menu ứng dụng:

- **Chơi trong cửa sổ**: trong game, `Alt+Enter` cũng chuyển qua lại.
- **Cài đặt hiển thị**: mở cửa sổ cấu hình của cnc-ddraw (shader, tỉ lệ, renderer).
- **Mở thư mục game**: save, bản đồ, campaign, mod.
- **Nhập lại game**: đổi bản khác; save cũ được giữ.

Có game nào trong thư mục thì menu có mục cho game đó: Age of Empires (bản
gốc), Rise of Rome, Age of Empires II, The Conquerors.

## Lệnh

| Lệnh | Việc |
|---|---|
| `aoe-linux` | Chơi (mặc định là Rise of Rome) |
| `aoe-linux play aoe1 \| aoe1x \| aoe2 \| aoe2x` | Chơi một game cụ thể |
| `aoe-linux windowed` | Chơi trong cửa sổ |
| `aoe-linux setup [ZIP\|THƯ_MỤC\|LINK]` | Nhập hoặc nhập lại game |
| `aoe-linux display` | Cài đặt hiển thị |
| `aoe-linux folder` | Mở thư mục game |
| `aoe-linux doctor` | Kiểm tra máy và bản cài khi có lỗi |
| `aoe-linux proxy [URL\|off]` | Lưu, xem hoặc bỏ proxy để tải |
| `aoe-linux uninstall` | Xoá game, save và Wine (có hỏi trước) |

Mọi thứ nằm trong `~/.local/share/aoe-linux`, file tải nằm trong
`~/.cache/aoe-linux`. Gỡ hẳn: `aoe-linux uninstall` rồi `sudo apt remove aoe-linux`
(hoặc `sh install.sh --uninstall` nếu cài không sudo).

## Gặp lỗi

- Chạy `aoe-linux doctor`: báo phiên bản Wine, thư viện còn thiếu, font, GPU
  và mấy dòng cuối của log lần chạy gần nhất (`~/.local/share/aoe-linux/last-run.log`).
- Chữ trong game bị ô vuông: `sudo apt install fonts-liberation`.
- Lần đầu bấm không thấy cửa sổ nào: `sudo apt install zenity`, hoặc cài bằng
  terminal với `aoe-linux setup <file.zip>`.
- Bản repack tiếng Trung hiện một dòng chữ lỗi font ở màn hình chính. Lỗi có sẵn
  trong bản repack, không ảnh hưởng gì khi chơi.

## Đã thử

Ubuntu 24.04, bản Rise of Rome: nhập từ zip, vào menu chính, Single Player →
Random Map → Start Game, vào trận, chữ rõ. Gói `.deb` được thử cài trên một máy
Ubuntu 24.04 trắng trong docker. Age of Empires II có hỗ trợ nhưng chưa được thử
với file game thật. Báo lỗi ở [Issues](https://github.com/DucLong06/aoe-linux/issues).

## Dựa trên

- [Wine](https://www.winehq.org/), bản build portable của [Kron4ek/Wine-Builds](https://github.com/Kron4ek/Wine-Builds)
- [cnc-ddraw](https://github.com/FunkyFr3sh/cnc-ddraw) của FunkyFr3sh
- Phiên bản và sha256 của cả hai được ghim trong script, tải về đều được kiểm tra.

Giấy phép MIT. Age of Empires là thương hiệu của Microsoft; dự án này không liên
quan tới Microsoft.

<p align="center">Cảm ơn <a href="https://github.com/NousResearch/hermes-agent">Hermes</a> và <a href="https://claude.ai">Claude</a> đã cùng làm dự án này 🇻🇳</p>

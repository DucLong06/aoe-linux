#!/usr/bin/env python3
"""Render assets/aoe-linux.svg to the PNG sizes the menu/dock need.

Dev-only: needs google-chrome (headless) and Pillow. The PNGs are committed,
so installing never needs this.
"""
import pathlib
import subprocess
import tempfile

from PIL import Image, ImageDraw

ROOT = pathlib.Path(__file__).resolve().parent.parent
SVG = ROOT / "assets" / "aoe-linux.svg"
OUT = ROOT / "assets" / "icons"
SIZES = [16, 24, 32, 48, 64, 128, 256, 512]

with tempfile.TemporaryDirectory() as tmp:
    shot = pathlib.Path(tmp) / "512.png"
    subprocess.run(
        ["google-chrome", "--headless", "--disable-gpu", "--hide-scrollbars",
         "--default-background-color=00000000", "--window-size=512,512",
         f"--screenshot={shot}", SVG.as_uri()],
        check=True, capture_output=True,
    )
    im = Image.open(shot).convert("RGBA")

# Chrome paints the page corners: cut them with the same squircle radius as the SVG
mask = Image.new("L", im.size, 0)
ImageDraw.Draw(mask).rounded_rectangle((0, 0, 511, 511), radius=112, fill=255)
im.putalpha(mask)
assert im.getpixel((0, 0))[3] == 0, "corner must be transparent"

OUT.mkdir(parents=True, exist_ok=True)
for s in SIZES:
    im.resize((s, s), Image.LANCZOS).save(OUT / f"{s}.png")
im.save(ROOT / "docs" / "icon.png")
print("ok", [f"{s}.png" for s in SIZES])

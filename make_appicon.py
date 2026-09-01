"""Build iOS app icons from the CMMS combined logo mark."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "logo-source.jpg"
OUT = ROOT / "ChildrensManorParent" / "Assets.xcassets" / "AppIcon.appiconset"
BLUE = (0, 91, 171, 255)
WHITE = (255, 255, 255, 255)
SIZE = 1024

SIZES = {
    "AppIcon-20@2x.png": 40,
    "AppIcon-20@3x.png": 60,
    "AppIcon-29@2x.png": 58,
    "AppIcon-29@3x.png": 87,
    "AppIcon-40@2x.png": 80,
    "AppIcon-40@3x.png": 120,
    "AppIcon-60@2x.png": 120,
    "AppIcon-60@3x.png": 180,
    "AppIcon-1024.png": 1024,
}


def extract_mark(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    w, h = rgba.size
    px = rgba.load()
    left, top, right, bottom = w, h, 0, 0
    # Logo mark lives in the left ~42% of the banner.
    x_limit = int(w * 0.42)
    for y in range(h):
        for x in range(x_limit):
            r, g, b, a = px[x, y]
            if r < 245 or g < 245 or b < 245:
                left = min(left, x)
                top = min(top, y)
                right = max(right, x)
                bottom = max(bottom, y)
    pad = 12
    box = (
        max(0, left - pad),
        max(0, top - pad),
        min(w, right + 1 + pad),
        min(h, bottom + 1 + pad),
    )
    return rgba.crop(box)


def make_master() -> Image.Image:
    src = Image.open(SRC)
    mark = extract_mark(src)
    canvas = Image.new("RGBA", (SIZE, SIZE), WHITE)
    # Thin school-blue ring so the white tile still reads as CMMS on the home screen.
    draw = ImageDraw.Draw(canvas)
    inset = 28
    draw.rounded_rectangle(
        (inset, inset, SIZE - inset - 1, SIZE - inset - 1),
        radius=96,
        outline=BLUE,
        width=18,
    )
    target = int(SIZE * 0.70)
    mw, mh = mark.size
    scale = min(target / mw, target / mh)
    nw, nh = max(1, int(mw * scale)), max(1, int(mh * scale))
    mark = mark.resize((nw, nh), Image.Resampling.LANCZOS)
    x = (SIZE - nw) // 2
    y = (SIZE - nh) // 2
    canvas.paste(mark, (x, y), mark)
    return canvas.convert("RGB")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    master = make_master()
    master.save(OUT / "AppIcon-1024.png", "PNG")
    for name, px in SIZES.items():
        if name == "AppIcon-1024.png":
            continue
        im = master.resize((px, px), Image.Resampling.LANCZOS)
        im.save(OUT / name, "PNG")
    print(f"Wrote {len(SIZES)} icons to {OUT}")


if __name__ == "__main__":
    main()

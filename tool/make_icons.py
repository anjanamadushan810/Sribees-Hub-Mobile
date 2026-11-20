"""Draw the SriBees Hub launcher icons (run from hub_app/: python tool/make_icons.py).

Pink background, white hive cell (hexagon) with a pink "S".
Writes legacy icons (API < 26) and adaptive-icon foregrounds (API 26+).
"""
import math
import os

from PIL import Image, ImageDraw, ImageFont

PINK = (0xD8, 0x1B, 0x60, 255)
WHITE = (255, 255, 255, 255)
FONT = r"C:\Windows\Fonts\segoeuib.ttf"
RES = os.path.join("android", "app", "src", "main", "res")
SS = 4  # supersampling for smooth edges

# density -> scale (mdpi = 1)
DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def hexagon(cx, cy, r):
    # Pointy-top hive cell.
    return [(cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a)))
            for a in range(-90, 270, 60)]


def draw_mark(d, size, cx, cy, r):
    d.polygon(hexagon(cx, cy, r), fill=WHITE)
    font = ImageFont.truetype(FONT, int(r * 1.15))
    d.text((cx, cy + r * 0.04), "S", font=font, fill=PINK, anchor="mm")


def legacy(px):
    big = px * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, big - 1, big - 1], radius=int(big * 0.22), fill=PINK)
    draw_mark(d, big, big / 2, big / 2, big * 0.33)
    return img.resize((px, px), Image.LANCZOS)


def foreground(px):
    # 108dp canvas; the safe zone is the centre 66dp circle (r = 33dp).
    big = px * SS
    img = Image.new("RGBA", (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_mark(d, big, big / 2, big / 2, big * (27 / 108))
    return img.resize((px, px), Image.LANCZOS)


for name, k in DENSITIES.items():
    folder = os.path.join(RES, f"mipmap-{name}")
    os.makedirs(folder, exist_ok=True)
    legacy(round(48 * k)).save(os.path.join(folder, "ic_launcher.png"))
    foreground(round(108 * k)).save(os.path.join(folder, "ic_launcher_foreground.png"))

os.makedirs(os.path.join(RES, "mipmap-anydpi-v26"), exist_ok=True)
with open(os.path.join(RES, "mipmap-anydpi-v26", "ic_launcher.xml"), "w", encoding="utf-8") as f:
    f.write(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
        '    <background android:drawable="@color/ic_launcher_background" />\n'
        '    <foreground android:drawable="@mipmap/ic_launcher_foreground" />\n'
        '</adaptive-icon>\n'
    )
with open(os.path.join(RES, "values", "ic_launcher_background.xml"), "w", encoding="utf-8") as f:
    f.write(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources>\n'
        '    <color name="ic_launcher_background">#D81B60</color>\n'
        '</resources>\n'
    )

# Preview for a human check.
legacy(512).save(os.path.join("tool", "icon-preview.png"))
print("icons written")

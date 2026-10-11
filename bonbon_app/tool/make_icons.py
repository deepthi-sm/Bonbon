#!/usr/bin/env python3
"""Make every app/browser icon from the one Bonbon logo.

  python tool/make_icons.py            # uses assets/brand/logo.png

Writes the browser tab icon (web/favicon.png), the install icons
(web/icons/*.png), the Android launcher icons (mipmap-*/ic_launcher.png) and
the loading-screen logo (web/splash-logo.png, drawable-nodpi/splash_logo.png).
The in-app logo (top bar, welcome screen, settings) reads
assets/brand/logo.png directly, so replacing that one file and running this
script updates the logo everywhere. Needs Pillow (pip install pillow).
"""
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'assets', 'brand', 'logo.png')


def square(img, size, pad=0.0, bg=None):
    """Fit the logo in a square canvas, with optional padding and background."""
    canvas = Image.new('RGBA', (size, size), bg or (0, 0, 0, 0))
    inner = int(size * (1 - 2 * pad))
    logo = img.copy()
    logo.thumbnail((inner, inner), Image.LANCZOS)
    canvas.alpha_composite(logo, ((size - logo.width) // 2, (size - logo.height) // 2))
    return canvas


def main():
    src = sys.argv[1] if len(sys.argv) > 1 else SRC
    if not os.path.exists(src):
        sys.exit(f'Logo not found: {src}\nSave the logo as a PNG at assets/brand/logo.png first.')
    img = Image.open(src).convert('RGBA')
    bbox = img.getbbox()  # trim empty transparent margins
    if bbox:
        img = img.crop(bbox)

    out = {
        'web/favicon.png': square(img, 64, pad=0.02),
        'web/icons/Icon-192.png': square(img, 192, pad=0.06),
        'web/icons/Icon-512.png': square(img, 512, pad=0.06),
        # maskable icons get cropped to a circle by the OS: keep the logo in the safe zone
        'web/icons/Icon-maskable-192.png': square(img, 192, pad=0.18, bg=(255, 255, 255, 255)),
        'web/icons/Icon-maskable-512.png': square(img, 512, pad=0.18, bg=(255, 255, 255, 255)),
    }
    for folder, size in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
        out[f'android/app/src/main/res/mipmap-{folder}/ic_launcher.png'] = square(
            img, size, pad=0.08, bg=(255, 255, 255, 255))

    # Loading screen: the web page shows it before the app code arrives,
    # Android draws it while the app process starts.
    splash = img.copy()
    splash.thumbnail((520, 520), Image.LANCZOS)
    splash = splash.quantize(colors=128, method=Image.FASTOCTREE, dither=Image.NONE)
    out['web/splash-logo.png'] = splash
    out['android/app/src/main/res/drawable-nodpi/splash_logo.png'] = splash

    for rel, im in out.items():
        path = os.path.join(ROOT, rel)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        im.save(path)
        print('wrote', rel)


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Remove white/near-white background from PNG images, making it transparent."""

import sys
from PIL import Image


def remove_white_bg(
    input_path: str,
    output_path: str,
    threshold: int = 235,
    soft_threshold: int = 215,
) -> None:
    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()
    w, h = img.size

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if r > threshold and g > threshold and b > threshold:
                pixels[x, y] = (r, g, b, 0)
            elif r > soft_threshold and g > soft_threshold and b > soft_threshold:
                avg = (r + g + b) / 3.0
                new_alpha = int(((255.0 - avg) / (255.0 - soft_threshold)) * 255)
                new_alpha = max(0, min(255, new_alpha))
                pixels[x, y] = (r, g, b, new_alpha)

    img.save(output_path, "PNG")
    print(f"Done: {output_path} ({w}x{h})")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: remove_white_bg.py <input.png> [output.png]")
        sys.exit(1)
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) >= 3 else input_file
    remove_white_bg(input_file, output_file)
